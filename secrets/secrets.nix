let
  users = import ../authorized_keys;

  systems = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsLlqDXl8kU+FfzJQpzPXQCfJdntfEDIaSDyfezy5Hy root@elitebook-835-g7"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJEBV9qA0qZIBdu1aL8DjXpKdtzl+Pf48LAy8PUaY3Q root@changwang-cw56-58"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII36AUr8me43Oj6ZTqgG+hylGl9jwny6m1wTtZERoxUo root@asustek"
  ];
in
{
  "user-password.age".publicKeys = systems;
}
