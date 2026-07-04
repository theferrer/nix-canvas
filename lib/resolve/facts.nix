{ lib }:
{
  software,
  requiredCapabilities,
  capabilityMap,
  lookDef,
  declaredGraphical,
}:
let
  desktopApp = capabilityMap.desktop or null;
in
{
  graphical =
    if declaredGraphical != null then declaredGraphical else lib.elem "desktop" requiredCapabilities;
  sessionProtocol =
    if desktopApp != null && (software ? ${desktopApp}) then
      software.${desktopApp}.sessionProtocol or null
    else
      null;
  style = lookDef.style or null;
}
