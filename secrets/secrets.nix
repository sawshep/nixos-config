let
  users = import ../authorized_keys;

  laptop =      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsLlqDXl8kU+FfzJQpzPXQCfJdntfEDIaSDyfezy5Hy root@elitebook-835-g7";
  server =      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJEBV9qA0qZIBdu1aL8DjXpKdtzl+Pf48LAy8PUaY3Q root@changwang-cw56-58";
  workstation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII36AUr8me43Oj6ZTqgG+hylGl9jwny6m1wTtZERoxUo root@asustek";
  seedbox =	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIbmZKe4en/4xIyxuL3DrE4W/HUmE61lbBXNs/HUik3Y root@seedbox";

  systems = [ laptop server workstation seedbox ];
in
{
  "user-password.age".publicKeys = systems;
  "caddy-basicauth.age".publicKeys = [ server ];
}
