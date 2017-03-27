# Photon

Photon was a remote for Philips Hue lights and is no longer maintained. It was the first app I released to the app store (in early 2015). Although the code quality isn't my greatest work and the UI is rather spartan, the app made interacting with the light system easier and it had a number of unique features that were unmatched in other Hue remote apps.

![Phone GIF](demo/photon-phone.gif "Photon running on iOS")

To adjust the color temperature or brightness, tap the group or light, select the color or OFF. Once a color is selected, the brightness sliders appear and allow for adjustments. Using the master slider at top adjusts the brightness of the lights proportionately, rather than setting each light to the same brightness.

### Notable features:
- Some Hue lights only have limited color capabilities which don't include setting color temperature. In Photon, I calculated the closest color temperature match from hue, saturation, and brightness values. This allowed the control of groups that include both types of lights.
- The brightness slider behavior is very useful and I haven't seen it in other lighting control apps.
- Long pressing and sliding to the desired color temperature makes adjustments even faster.

## Photon watch app

![Watch GIF](demo/photon-watch.gif "Photon running on watchOS")

The watch app was written for watchOS 1. The "Others OFF" feature made adjusting a light or group and turning other lights off super quick. I haven't seen this in other apps, but it was probably the most useful button in the app. Force pressing from any screen allowed you to turn all the lights off or on, as well as adjust the brightness and color temperature.
