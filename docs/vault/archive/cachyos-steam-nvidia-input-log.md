n# CachyOS Steam / NVIDIA / Input Issue Log (June 2026)

## Symptoms

After multiple fresh CachyOS installations:

* Steam behaved inconsistently.
* Keyboard input would disappear after logging into KDE.
* The RTX 3060 appeared not to be fully utilized.
* The desktop sometimes seemed to fall back to the Ryzen 5700G iGPU.
* `nvidia-smi` eventually reported:

  ```
  Failed to initialize NVML: Driver/library version mismatch
  ```

Initially, the Tesla P40 and dual-GPU configuration were suspected.

## Hardware

* AMD Ryzen 7 5700G
* NVIDIA RTX 3060
* NVIDIA Tesla P40
* KDE Plasma
* Wayland
* CachyOS

## Investigation

### Tesla P40

The Tesla was removed and the OS reinstalled multiple times.

Result:

* Problem persisted.
* Tesla P40 was not the cause.

A known-good configuration exists with:

* RTX 3060
* Tesla P40
* NVIDIA 580.159.04
* CUDA 13.0
* Steam functioning normally.

### Display configuration

Initially tested with:

* Two monitors on RTX 3060.
* One monitor on 5700G.

Later moved all displays to the RTX 3060.

Result:

* Keyboard issue remained.
* Mixed-display setup was not the root cause.

### Input stack

The command:

```bash
sudo pacman -S libinput
```

resolved the keyboard/input problems.

Conclusion:

* An incomplete or broken libinput stack can cause severe Wayland keyboard failures that may appear to be Steam or GPU issues.

### NVIDIA stack

At one point:

```
nvidia-smi
Driver Version: 610.xx
```

Later:

```
NVML library version: 580.159
Driver/library version mismatch
```

Reinstalling the 580 driver stack restored proper operation.

Known-good state:

```
Driver Version: 580.159.04
CUDA Version: 13.0
RTX 3060 detected
Tesla P40 detected
```

## Verified Working NVIDIA Packages

```
nvidia-580xx-dkms
nvidia-580xx-utils
lib32-nvidia-580xx-utils
opencl-nvidia-580xx
lib32-opencl-nvidia-580xx
```

`nvidia-smi` should successfully enumerate both GPUs.

## Lessons Learned

* Do not immediately blame the Tesla P40.
* NVIDIA 580.159.04 + CUDA 13.0 is a known stable configuration for this hardware.
* Missing `libinput` can produce keyboard and Steam symptoms that resemble GPU failures.
* Driver/library mismatches can create cascading graphics issues.
* Verify `nvidia-smi` before assuming Steam is broken.
* A fresh reinstall does not guarantee that all required input packages are present.

## Useful Diagnostics

Check session type:

```bash
echo $XDG_SESSION_TYPE
```

Check NVIDIA status:

```bash
nvidia-smi
```

Check installed NVIDIA packages:

```bash
pacman -Q | grep nvidia
```

Verify libinput:

```bash
pacman -Q libinput
```

## Recovery Checklist

1. Verify `libinput` is installed.
2. Verify `nvidia-smi` works without NVML errors.
3. Confirm all NVIDIA packages are on the 580.159.04 branch.
4. Reboot.
5. Test Steam.
6. Only investigate Steam itself after input and NVIDIA stacks are confirmed healthy.

## Conclusion

The issue was not caused by the Tesla P40 or Steam itself.

The failure was the combination of:

* an incomplete input stack (`libinput`),
* a temporarily inconsistent NVIDIA installation,
* and resulting Wayland/desktop instability.

Known-good baseline:

* CachyOS
* KDE Plasma
* Wayland
* RTX 3060 + Tesla P40
* NVIDIA 580.159.04
* CUDA 13.0
* `libinput` installed
* Steam operational.
