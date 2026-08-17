import ApplicationServices
import CoreAudio

// MARK: - Audio Volume Control

struct VolumeChannel {
    var device: AudioDeviceID
    var channel: UInt32
    var scope: AudioObjectPropertyScope
}

nonisolated(unsafe) var savedVolumes: [(channel: VolumeChannel, volume: Float32)] = []
nonisolated(unsafe) var isDucked = false

func getDefaultOutputDevice() -> AudioDeviceID? {
    var deviceID = AudioDeviceID()
    var size = UInt32(MemoryLayout<AudioDeviceID>.size)
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultOutputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    let status = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &deviceID
    )
    if status != noErr { return nil }
    return deviceID
}

func getVolumeChannels(device: AudioDeviceID) -> [VolumeChannel] {
    let scope = kAudioDevicePropertyScopeOutput
    // Try master channel (element 0) first
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyVolumeScalar,
        mScope: scope,
        mElement: 0
    )
    if AudioObjectHasProperty(device, &address) {
        return [VolumeChannel(device: device, channel: 0, scope: scope)]
    }
    // Fall back to stereo channels 1 and 2
    var channels: [VolumeChannel] = []
    for ch: UInt32 in [1, 2] {
        address.mElement = ch
        if AudioObjectHasProperty(device, &address) {
            channels.append(VolumeChannel(device: device, channel: ch, scope: scope))
        }
    }
    return channels
}

func getVolume(_ channel: VolumeChannel) -> Float32? {
    var volume = Float32(0)
    var size = UInt32(MemoryLayout<Float32>.size)
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyVolumeScalar,
        mScope: channel.scope,
        mElement: channel.channel
    )
    let status = AudioObjectGetPropertyData(channel.device, &address, 0, nil, &size, &volume)
    if status != noErr { return nil }
    return volume
}

func setVolume(_ channel: VolumeChannel, _ volume: Float32) {
    var vol = volume
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyVolumeScalar,
        mScope: channel.scope,
        mElement: channel.channel
    )
    AudioObjectSetPropertyData(
        channel.device, &address, 0, nil, UInt32(MemoryLayout<Float32>.size), &vol
    )
}

func duck() {
    guard !isDucked else { return }
    guard let device = getDefaultOutputDevice() else { return }
    let channels = getVolumeChannels(device: device)
    if channels.isEmpty { return }

    savedVolumes = []
    for ch in channels {
        if let vol = getVolume(ch) {
            savedVolumes.append((channel: ch, volume: vol))
            setVolume(ch, vol * 0.2)
        }
    }
    isDucked = true
}

func unduck() {
    guard isDucked else { return }
    for entry in savedVolumes {
        setVolume(entry.channel, entry.volume)
    }
    savedVolumes = []
    isDucked = false
}

// MARK: - Keyboard Event Tap

nonisolated(unsafe) var eventTap: CFMachPort?

let rightOptionKeycode: UInt16 = 61

func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    if type == .tapDisabledByTimeout {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        return Unmanaged.passUnretained(event)
    }

    guard type == .flagsChanged else {
        return Unmanaged.passUnretained(event)
    }

    let keycode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    if keycode == rightOptionKeycode {
        let flags = event.flags
        if flags.contains(.maskAlternate) {
            duck()
        } else {
            unduck()
        }
    }

    return Unmanaged.passUnretained(event)
}

// MARK: - Main

// Prompt the user to grant Accessibility permission if not already trusted,
// then wait for it to be granted.
if !AXIsProcessTrusted() {
    let axOptions = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
    _ = AXIsProcessTrustedWithOptions(axOptions)
    while !AXIsProcessTrusted() {
        sleep(1)
    }
}

let eventMask: CGEventMask = 1 << CGEventType.flagsChanged.rawValue
guard let tap = CGEvent.tapCreate(
    tap: .cgSessionEventTap,
    place: .headInsertEventTap,
    options: .listenOnly,
    eventsOfInterest: eventMask,
    callback: eventTapCallback,
    userInfo: nil
) else {
    fputs("Error: Failed to create event tap. Check accessibility permissions.\n", stderr)
    exit(1)
}
eventTap = tap

let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
CGEvent.tapEnable(tap: tap, enable: true)

print("duck-key: Running. Hold right Option key to duck audio.")
CFRunLoopRun()
