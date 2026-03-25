#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2022/1/4 19:44
# @Author  : Yaojie Shen
# @File    : housekeeper.py

import argparse
import gc
import logging
import os.path
import subprocess
import threading
import time
import socket
import atexit
import json
import os
from multiprocessing import Process, Lock, Event
from typing import Optional, List

import torch

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.DEBUG)


class GPUWorker:
    def __init__(self, device_id: int):
        self.device = device_id

        self._net = None
        self._inputs = None

        self.control_lock = Lock()
        self.enabled = Event()

        # Start a daemon target at given GPU
        self.daemon_worker = Process(target=self._run)
        self.daemon_worker.start()

    @property
    def inputs(self):
        if self._inputs is None:
            self._inputs = torch.rand((1, 3, 6, 64, 64), device=torch.device(self.device))
        return self._inputs

    @property
    def net(self):
        if self._net is None:
            self._net = torch.nn.Conv3d(3, 3, (4, 16, 16), device=torch.device(self.device))
        return self._net

    def clean(self):
        self._net = None
        self._inputs = None
        gc.collect()
        torch.cuda.empty_cache()

    @torch.no_grad()
    def _run(self):
        while True:
            if self.is_enabled():
                self.net(self.inputs)
            else:
                self.clean()

    def enable(self):
        with self.control_lock:
            self.enabled.set()

    def disable(self):
        with self.control_lock:
            self.enabled.clear()

    def is_enabled(self):
        with self.control_lock:
            return self.enabled.is_set()


class GPUStatus:
    def __init__(
            self,
            device_id: Optional[int] = None,
            using_utilization_threshold: float = 50.0,
            using_memory_threshold: float = 1024 * 2,
            update_interval: int = 1,
            short_window: int = 60,
            long_window: int = 60 * 60 * 3
    ):
        self.device_id = device_id

        self._access_lock = threading.Lock()
        # short window: recent snapshot; long window: 3h stats
        self._utilization_history = [0.0]
        self._memory_history = [0.0]
        self._utilization_history_long = [0.0]
        self._memory_history_long = [0.0]

        self._update_interval = max(int(update_interval), 1)
        self._short_window = max(int(short_window), self._update_interval)
        self._long_window = max(int(long_window), self._short_window)

        self._check_thread = threading.Thread(target=self._gpu_check_daemon)
        self._check_thread.start()

        self._using_utilization_threshold = using_utilization_threshold
        self._using_memory_threshold = using_memory_threshold

    @property
    def utilization(self):
        """
        check once
        @return: average GPU utilization (percentage)
        """
        for i in range(60):
            try:
                cmd = ['nvidia-smi', '--query-gpu=utilization.gpu', '--format=csv']
                if self.device_id is not None:
                    cmd += [f"-i={self.device_id}"]
                utilization = subprocess.run(
                    args=cmd,
                    stdout=subprocess.PIPE
                ).stdout.decode('utf-8')
                utilization = [float(x[:-2]) for x in utilization.split("\n")[1:-1]]  # TODO: Use regx to match
                if len(utilization):
                    return sum(utilization) / len(utilization)
                else:
                    return None
            except Exception as e:
                logger.warning("Got exception while getting GPU utilization: %s", e)
        raise RuntimeError("Failed to get GPU utilization after retry for many times")

    @property
    def memory(self):
        """
        check once
        @return: average GPU memory usage (MB)
        """
        for i in range(60):
            try:
                cmd = ['nvidia-smi', '--query-gpu=memory.used', '--format=csv']
                if self.device_id is not None:
                    cmd += [f"-i={self.device_id}"]
                memory = subprocess.run(
                    args=cmd,
                    stdout=subprocess.PIPE
                ).stdout.decode('utf-8')
                memory = [float(x[:-4]) for x in memory.split("\n")[1:-1]]  # TODO: Use regx to match
                if len(memory):
                    return int(sum(memory) / len(memory))
                else:
                    return None
            except Exception as e:
                logger.warning("Got exception while getting GPU memory usage: %s", e)
        raise RuntimeError("Failed to get GPU memory usage after retry for many times")

    def _gpu_check_daemon(self):
        """
        Keep check the gpu utilization and memory, and write them to history.

        Uses self._update_interval, self._short_window, self._long_window
        """
        update_duration = self._update_interval
        while True:
            start_time = time.time()

            # Get current GPU status
            cur_utilization = self.utilization
            cur_memory = self.memory

            # Write to history
            if cur_utilization is not None and cur_memory is not None:
                with self._access_lock:
                    # Limit history size (short)
                    short_size = max(self._short_window // update_duration, 1)
                    long_size = max(self._long_window // update_duration, 1)
                    self._utilization_history = self._utilization_history[-short_size + 1:]
                    self._memory_history = self._memory_history[-short_size + 1:]
                    self._utilization_history_long = self._utilization_history_long[-long_size + 1:]
                    self._memory_history_long = self._memory_history_long[-long_size + 1:]

                    self._utilization_history.append(cur_utilization)
                    self._memory_history.append(cur_memory)
                    self._utilization_history_long.append(cur_utilization)
                    self._memory_history_long.append(cur_memory)

            end_time = time.time()
            time.sleep(max(update_duration - (end_time - start_time), 0))

    def snapshot(self):
        """Average utilization and memory over the short window (MB)."""
        with self._access_lock:
            util = round(sum(self._utilization_history) / len(self._utilization_history), 1)
            mem = round(sum(self._memory_history) / len(self._memory_history), 1)
        return util, mem

    def snapshot_long(self):
        """Average utilization and memory over the long window (default 3h)."""
        with self._access_lock:
            util = round(sum(self._utilization_history_long) / len(self._utilization_history_long), 1)
            mem = round(sum(self._memory_history_long) / len(self._memory_history_long), 1)
        return util, mem

    @property
    def is_using(self):
        avg_utilization = round(sum(self._utilization_history) / len(self._utilization_history), 1)
        avg_memory = round(sum(self._memory_history) / len(self._memory_history), 1)
        return avg_utilization > self._using_utilization_threshold and avg_memory > self._using_memory_threshold


class GPUStatusController:
    """Auto controller: decide enable/disable from GPU usage with hysteresis timers."""
    def __init__(self, utilization_threshold=50.0, memory_threshold=5120,
                 using_timeout=10, idle_timeout=10):
        self.status = GPUStatus(using_utilization_threshold=utilization_threshold,
                                using_memory_threshold=memory_threshold)
        self.using_timeout = using_timeout
        self.idle_timeout = idle_timeout
        self._last_using = None
        self._using_start = time.time()
        self._idle_start = time.time()
        # desired state: True=enable, False=disable
        self._desired_enabled = False

    def get_control(self) -> dict:
        now = time.time()
        is_using = self.status.is_using
        info = {}
        # keep previous by default; flip only when thresholds hit
        desired = self._desired_enabled

        # reset timers on state change
        if is_using:
            if self._last_using is not True:
                self._using_start = now
            active_secs = int(now - self._using_start)
            info["active_secs"] = active_secs
            if active_secs > self.using_timeout:
                desired = False
        else:
            if self._last_using is not False:
                self._idle_start = now
            inactive_secs = int(now - self._idle_start)
            info["inactive_secs"] = inactive_secs
            if inactive_secs > self.idle_timeout:
                desired = True

        util, mem = self.status.snapshot()
        util3h, _ = self.status.snapshot_long()
        info["util"] = util
        info["mem"] = mem
        info["util3h"] = util3h
        self._last_using = is_using
        # persist desired state and return boolean decision
        self._desired_enabled = desired
        return {"desired_enable": self._desired_enabled, **info}


class CommandController:
    """External command controller (socket/file -> control dict).
    Keys:
      - mode: 'auto' | 'enabled' | 'disabled'
      - pause_remaining / pause_total (seconds)
    """
    def __init__(self, control_socket: str = "/tmp/housekeeper_ctl.sock", control_file: str = "/tmp/housekeeper_ctl"):
        self.ctrl_path = control_socket
        self.control_file = control_file
        self._sock = None
        self.pause_until = None  # epoch seconds
        self.pause_total = 0
        # persistent mode: 'auto' | 'enabled' | 'disabled'
        self.mode = 'auto'
        # init socket
        try:
            if os.path.exists(self.ctrl_path):
                try:
                    os.remove(self.ctrl_path)
                except Exception:
                    pass
            self._sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
            self._sock.bind(self.ctrl_path)
            self._sock.setblocking(False)
            try:
                os.chmod(self.ctrl_path, 0o600)
            except Exception:
                pass
            atexit.register(lambda: os.path.exists(self.ctrl_path) and os.remove(self.ctrl_path))
            logger.info("control socket ready at %s", self.ctrl_path)
        except Exception as e:
            logger.warning("failed to init control socket %s: %s", self.ctrl_path, e)
            self._sock = None

    def _check_control_file(self):
        if os.path.exists(self.control_file):
            try:
                with open(self.control_file, "r") as f:
                    sec = int(f.readline())
                sec = max(sec, 0)
                self.pause_until = time.time() + sec
                self.pause_total = sec
            except (ValueError, FileNotFoundError):
                pass
            finally:
                try:
                    os.remove(self.control_file)
                except Exception:
                    pass

    def _poll_socket(self):
        if self._sock is None:
            return
        while True:
            try:
                data = self._sock.recv(1024)
            except BlockingIOError:
                break
            except Exception as e:
                logger.warning("control recv error: %s", e)
                break
            cmd = data.decode("utf-8", errors="ignore").strip()
            if not cmd:
                continue
            parts = cmd.split()
            op = parts[0].lower()
            if op == "pause":
                sec = 1800
                if len(parts) >= 2 and parts[1].isdigit():
                    sec = int(parts[1])
                sec = max(sec, 0)
                self.pause_until = time.time() + sec
                self.pause_total = sec
                logger.info("received control: pause %ss", sec)
            elif op == "enable":
                self.pause_until = None
                self.pause_total = 0
                self.mode = 'enabled'
                logger.info("received control: enable (mode=enabled)")
            elif op == "disable":
                self.mode = 'disabled'
                logger.info("received control: disable (mode=disabled)")
            elif op == "auto":
                self.mode = 'auto'
                logger.info("received control: auto (mode=auto)")
            else:
                logger.warning("unknown control: %s", cmd)

    def get_control(self) -> dict:
        # poll sources
        self._check_control_file()
        self._poll_socket()
        # compute remaining
        now = time.time()
        remaining = 0
        if self.pause_until is not None:
            remaining = int(self.pause_until - now)
            if remaining <= 0:
                self.pause_until = None
                remaining = 0
        out = {"mode": self.mode}
        if remaining > 0:
            out["pause_remaining"] = remaining
            out["pause_total"] = max(int(self.pause_total), remaining)
        return out


class DatagramPublisher:
    """UNIX DGRAM publisher at control_socket + '.pub'."""
    def __init__(self, control_socket: str):
        self.pub_path = control_socket + ".pub"
        self._sock = None
        self._subs = set()        # set of address (client path strings)
        self._last = {}           # addr -> last_monotonic
        self._started = False
        try:
            if os.path.exists(self.pub_path):
                try:
                    os.remove(self.pub_path)
                except Exception:
                    pass
            self._sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
            self._sock.bind(self.pub_path)
            self._sock.setblocking(False)
            try:
                os.chmod(self.pub_path, 0o600)
            except Exception:
                pass
            self._started = True
        except Exception as e:
            logger.warning("failed to init publish socket %s: %s", self.pub_path, e)
            self._sock = None
        atexit.register(self._cleanup)

    def _cleanup(self):
        try:
            if self._sock is not None:
                try:
                    self._sock.close()
                except Exception:
                    pass
        finally:
            try:
                if os.path.exists(self.pub_path):
                    os.remove(self.pub_path)
            except Exception:
                pass

    def recv_loop_step(self):
        if not self._started or self._sock is None:
            return
        while True:
            try:
                data, addr = self._sock.recvfrom(4096)
            except BlockingIOError:
                break
            except Exception:
                break
            try:
                msg = json.loads(data.decode('utf-8')) if data else {}
            except Exception:
                continue
            op = str(msg.get('op', '')).lower()
            if not addr:
                continue
            now = time.monotonic()
            if op == 'sub':
                self._subs.add(addr)
                self._last[addr] = now
            elif op == 'hb':
                self._last[addr] = now
            elif op == 'unsub':
                self._subs.discard(addr)
                self._last.pop(addr, None)

    def prune_stale(self, ttl: float = 3.0):
        if not self._started or self._sock is None:
            return
        now = time.monotonic()
        stale = [a for a, t0 in list(self._last.items()) if now - t0 > ttl]
        for a in stale:
            self._subs.discard(a)
            self._last.pop(a, None)

    def broadcast(self, payload: bytes):
        if not self._started or self._sock is None or not self._subs:
            return
        for a in list(self._subs):
            try:
                self._sock.sendto(payload, a)
            except Exception:
                self._subs.discard(a)
                self._last.pop(a, None)


# =========================
# Shared UI rendering
# =========================
RESET='\x1b[0m'; BOLD='\x1b[1m'
FG_RED='\x1b[31m'; FG_GREEN='\x1b[32m'; FG_YELLOW='\x1b[33m'; FG_BLUE='\x1b[34m'; FG_MAGENTA='\x1b[35m'; FG_CYAN='\x1b[36m'; FG_GRAY='\x1b[90m'

def _color(text, fg=None, bold=False):
    s = ''
    if bold:
        s += BOLD
    if fg:
        s += fg
    s += str(text) + RESET
    return s

def colored_bar(cur, total, width=30):
    try:
        cur = float(cur); total = float(total)
    except Exception:
        cur = 0.0; total = 1.0
    if total <= 0:
        total = 1.0
    ratio = max(0.0, min(1.0, cur/total))
    filled = int(width * ratio)
    if ratio < 0.6:
        fg = FG_GREEN
    elif ratio < 0.85:
        fg = FG_YELLOW
    else:
        fg = FG_RED
    bar_fill = _color('#'*filled, fg)
    bar_rest = '-'*(width-filled)
    return '[' + bar_fill + bar_rest + ']' + f" {int(ratio*100):3d}%"

def normalize_snapshot(snap: dict) -> dict:
    s = dict(snap or {})
    s.setdefault('mode', 'auto')
    s['keeping'] = bool(s.get('keeping', False))
    if 'decision' not in s or not s.get('decision'):
        s['decision'] = 'enabled' if s['keeping'] else 'disabled'
    return s

def render_line(snap: dict) -> str:
    s = normalize_snapshot(snap)
    ts = time.strftime('[%H:%M:%S]')
    parts = [
        f"Mode={str(s['mode']).upper()}",
        f"Keeping={'ON' if s['keeping'] else 'OFF'}",
        f"Decision={str(s['decision']).upper()}",
    ]
    if 'util' in s:
        parts.append(f"Util={float(s['util']):.1f}%")
    if 'util3h' in s:
        parts.append(f"Util3h={float(s['util3h']):.1f}%")
    if 'mem' in s:
        parts.append(f"Mem={int(float(s['mem']))}MB")
    if 'pause_remaining' in s and 'pause_total' in s:
        parts.append(f"Pause={int(s['pause_remaining'])}/{int(s['pause_total'])}s")
    return ts + ' ' + ', '.join(parts)

def render_ansi(snap: dict) -> str:
    s = normalize_snapshot(snap)
    ts = time.strftime('[%H:%M:%S]')
    title = _color('Housekeeper', FG_CYAN, True) + '  ' + _color(ts, FG_GRAY)
    keep_col = _color('ON', FG_GREEN, True) if s['keeping'] else _color('OFF', FG_RED, True)

    mode_str = str(s['mode']).upper()
    mode_col = {'AUTO': FG_BLUE, 'ENABLED': FG_GREEN, 'DISABLED': FG_RED}.get(mode_str, FG_GRAY)
    dec = str(s['decision']).lower()
    dec_col = {'manual_enable': FG_GREEN, 'auto_enable': FG_GREEN, 'enabled': FG_GREEN,
               'manual_disable': FG_RED, 'auto_disable': FG_RED, 'disabled': FG_RED,
               'pause': FG_MAGENTA}.get(dec, FG_GRAY)
    state = f"State: Keeping={keep_col}  Mode={_color(mode_str, mode_col, True)}  Decision={_color(dec.upper(), dec_col, True)}"

    util = float(s.get('util', 0.0))
    util3 = float(s.get('util3h', 0.0))
    mem = float(s.get('mem', 0.0))
    util_bar = colored_bar(util, 100, 30)
    util3_bar = colored_bar(util3, 100, 30)
    mem_cap = 32768 if mem <= 0 else max(4096, int(max(mem*1.2, 32768)))
    mem_bar = colored_bar(mem, mem_cap, 30)

    pr = s.get('pause_remaining'); pt = s.get('pause_total', pr if pr else 0)
    if pr and pt:
        ratio = max(0.0, min(1.0, int(pr)/max(int(pt),1)))
        width=30; filled=int(width*ratio)
        pause_bar = '[' + _color('#'*filled, FG_MAGENTA) + '-'*(width-filled) + ']' + f" {int(pr)}/{int(pt)}s"
    else:
        pause_bar = 'None'

    lines = [title, state]
    if 'active_secs' in s:
        lines.append(f"Active:   {int(s['active_secs']):5d}s")
    if 'inactive_secs' in s:
        lines.append(f"Inactive: {int(s['inactive_secs']):5d}s")
    lines.append(f"Util:     {util:5.1f}%  {util_bar}")
    lines.append(f"Util(3h): {util3:5.1f}%  {util3_bar}")
    lines.append(f"Mem:      {int(mem):5d}MB {mem_bar}")
    lines.append(f"Pause: {pause_bar}")
    return '\x1b[2J\x1b[H' + '\n'.join(lines)


class Housekeeper:
    def __init__(
            self,
            devices: List[int],
            utilization_threshold=50.0, memory_threshold=5120,
            pause_file="/tmp/housekeeper_ctl",
            control_socket: str = "/tmp/housekeeper_ctl.sock",
            ui_mode: str = "line"
    ):
        self._workers = [GPUWorker(i) for i in devices]
        # controllers
        self.status_ctrl = GPUStatusController(utilization_threshold, memory_threshold,
                                               using_timeout=10, idle_timeout=10)
        self.cmd_ctrl = CommandController(control_socket=control_socket, control_file=pause_file)
        self.ui_mode = ui_mode
        # publisher
        self.publisher = DatagramPublisher(control_socket)

    def start(self):
        # for dynamic status line
        self._line_len = 0
        tick = 0

        def keeping_now():
            try:
                return any(w.is_enabled() for w in self._workers)
            except Exception:
                return False
        while True:
            # gather control results
            cmd = self.cmd_ctrl.get_control()
            stat = self.status_ctrl.get_control()

            # merge
            # read current state to decide transitions
            currently_enabled = keeping_now()
            final_enable = None
            mode = cmd.get("mode", "auto")
            if cmd.get("pause_remaining", 0) > 0:
                final_enable = False
                decision = "pause"
            elif mode == 'enabled':
                final_enable = True
                decision = "manual_enable"
            elif mode == 'disabled':
                final_enable = False
                decision = "manual_disable"
            else:
                final_enable = stat.get("desired_enable")
                decision = "auto_enable" if final_enable else "auto_disable"

            # apply to workers
            if final_enable is True and not currently_enabled:
                for w in self._workers:
                    w.enable()
            elif final_enable is False and currently_enabled:
                for w in self._workers:
                    w.disable()

            # info dict for logging
            keeping = keeping_now()
            info = {"Keeping": keeping, "Mode": mode}
            if "active_secs" in stat:
                info["User Active"] = stat['active_secs']
            if "inactive_secs" in stat:
                info["User Inactive"] = stat['inactive_secs']
            if cmd.get("pause_remaining", 0) > 0:
                r = cmd['pause_remaining']
                t = cmd.get('pause_total', r)
                bar_len = 20
                filled = int(bar_len * max(min(r / max(t,1), 1.0), 0.0))
                bar = '[' + ('#' * filled) + ('-' * (bar_len - filled)) + ']'
                info["Pause"] = f"{r}/{t}s {bar}"
            # metrics
            util = stat.get('util')
            mem = stat.get('mem')
            if util is not None:
                info["Util"] = f"{util}%"
            util3h = stat.get('util3h')
            if util3h is not None:
                info["Util3h"] = f"{util3h}%"
            if mem is not None:
                info["Mem"] = f"{int(mem)}MB"
            info["Decision"] = decision

            # publish snapshot (JSON compact)
            snap = {
                "v": 1,
                "ts": int(time.time() * 1000),
                "mode": mode,
                "keeping": bool(keeping),
                "decision": decision,
            }
            # attach metrics if present
            if "Util" in info:
                try:
                    snap["util"] = float(info["Util"].rstrip('%'))
                except Exception:
                    pass
            if "Util3h" in info:
                try:
                    snap["util3h"] = float(info["Util3h"].rstrip('%'))
                except Exception:
                    pass
            if "Mem" in info:
                try:
                    snap["mem"] = int(str(info["Mem"]).rstrip('MB'))
                except Exception:
                    pass
            if "User Active" in info:
                try:
                    snap["active_secs"] = info["User Active"]
                except Exception:
                    pass
            if "User Inactive" in info:
                try:
                    snap["inactive_secs"] = info["User Inactive"]
                except Exception:
                    pass
            if cmd.get("pause_remaining"):
                snap["pause_remaining"] = int(cmd["pause_remaining"]) 
                if cmd.get("pause_total"):
                    snap["pause_total"] = int(cmd["pause_total"]) 
            try:
                payload = json.dumps(snap, separators=(",", ":")).encode("utf-8")
                self.publisher.recv_loop_step()
                self.publisher.prune_stale()
                self.publisher.broadcast(payload)
            except Exception:
                pass

            # render UI using shared functions defined in this module
            if self.ui_mode == 'ansi':
                screen = render_ansi(snap)
                print(screen, end='', flush=True)
            else:
                # dynamic status line (single-line refresh)
                line = render_line(snap)
                pad = max(self._line_len - len(line), 0)
                print("\r" + line + (" " * pad), end="", flush=True)
                self._line_len = len(line)

            tick += 1

            time.sleep(0.5)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--control_file", default="/tmp/housekeeper_ctl", type=str, help="control file for pause fallback")
    parser.add_argument("--control_socket", default="/tmp/housekeeper_ctl.sock", type=str, help="unix socket for control")
    parser.add_argument("--ui", choices=["line", "ansi"], default="line", help="UI mode: line|ansi")
    args = parser.parse_args()
    housekeeper = Housekeeper(devices=list(range(torch.cuda.device_count())), pause_file=args.control_file,
                              control_socket=args.control_socket, ui_mode=args.ui)
    housekeeper.start()
