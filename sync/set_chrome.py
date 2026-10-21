# Chrome OptGuideOnDeviceModel随意拉屎 占用4G空间
import json
import shutil
import subprocess
from pathlib import Path

apps = ["/Applications/Google Chrome.app/Contents", "/Applications/ego lite.app/Contents"]
for app in apps:
    if subprocess.run(["pgrep", "-f", app], stdout=subprocess.DEVNULL).returncode == 0:
        raise SystemExit(f"请先退出：{app}")

flag = "optimization-guide-on-device-model@2"
roots = [
    Path.home() / "Library/Application Support/Google/Chrome",
    Path.home() / "Library/Application Support/Citro Labs/ego lite",
]

for root in roots:
    state = root / "Local State"
    if not state.exists():
        continue
    backup = state.with_name("Local State.backup")
    if not backup.exists():
        shutil.copy2(state, backup)
    data = json.loads(state.read_text())
    flags = data.setdefault("enabled_labs_experiments", [])
    prefix = flag.split("@")[0]
    flags[:] = [item for item in flags if not item.startswith(prefix)] + [flag]
    state.write_text(json.dumps(data, separators=(",", ":")))
    shutil.rmtree(root / "OptGuideOnDeviceModel", ignore_errors=True)
    print(f"已设置并清理：{root}")
