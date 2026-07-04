{
  desktop = {
    description = "Graphical session: window manager, compositor or desktop environment.";
    requiresGraphical = true;
  };
  login-manager = {
    description = "Login / display manager starting the session.";
    requiresGraphical = true;
  };
  terminal = {
    description = "Terminal emulator.";
    requiresGraphical = true;
  };
  editor = {
    description = "Text editor.";
    requiresGraphical = false;
  };
  browser = {
    description = "Web browser.";
    requiresGraphical = true;
  };
  shell = {
    description = "Interactive shell.";
    requiresGraphical = false;
  };
  launcher = {
    description = "Application launcher / runner.";
    requiresGraphical = true;
  };
  notifications = {
    description = "Notification daemon.";
    requiresGraphical = true;
  };
  bar = {
    description = "Status bar / panel.";
    requiresGraphical = true;
  };
  file-manager = {
    description = "File manager.";
    requiresGraphical = false;
  };
  screenshot = {
    description = "Screenshot tooling.";
    requiresGraphical = true;
  };
  wallpaper = {
    description = "Wallpaper setter.";
    requiresGraphical = true;
  };
  screen-locker = {
    description = "Screen locker.";
    requiresGraphical = true;
  };
  pdf-viewer = {
    description = "PDF viewer.";
    requiresGraphical = true;
  };
  image-viewer = {
    description = "Image viewer.";
    requiresGraphical = true;
  };
  video-player = {
    description = "Video player.";
    requiresGraphical = true;
  };
  audio-player = {
    description = "Audio player.";
    requiresGraphical = false;
  };
}
