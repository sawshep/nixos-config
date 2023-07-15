let
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHe4JdAXSDsJFeVAlY9vq+y3mFDZIPoBArAIfgt38vEW";
  laptop = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCmWMUbI8KGFgjyHgcvwQ30iE2WUGNf1fbJsU0Pi7D2fUxPZ3x657gSSPpIkpdVGQT2bcDBiJLaV9sZW/ky6V1LidI4SWqD4MwnjSz8hRyVdR+Il1Aw6WcJ5qgfa9HtPZEqNqqRYGXOh65SeU/OlR2ZJ1UOOhTx8WkafZQlvI5Ze8NrUAtNwkXBGOwRuyCkIaeq/hlRl4paHV3gBDkkgC5McGMy9Dj2m3ibMEvtmPaMCb/huxvxOY8IsdVW15sbrfWfMlVGCVORzDj65RU46fJ5pGf5rxyMWEoe3+Dynjzdykyt7L1iBdEIAuM+eDN+cSlJsJQcteVEzw5ygKxUH0dn+pIjc+aLCi8UZVBNJYYRO1TemFYXEInGX9dVmCVzg32xvcMnWkvFbgXrzhHDPlLcjHP4vl3n/MV42SiEKHxMnX7Kp+/F0sTZZ5lS2oUUusWwEoPG3QhJI+Ym7v+Ts7TvI1K3W/t95YckikyzrjIso20lsCrandLS/S7fvkwHV7CuoGqAIMJ5W/r3bYuZWqZ+Aqw0AUmrnQ655rPUN/2LD0gRDq/wiUShZ5mz/hkwYVP5Npxni5J2GRkgsAmHk7KrZv2IWs4YkuajzI0PS68WI7ivM4OWZOUxRV9iZfowDd+0rMKakgKvcmUQ4t1R5atrTv4ZAsXsbIRMkMV4MxjdIw==";
  users = [ user laptop ];

  changwang-cw56-58 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJEBV9qA0qZIBdu1aL8DjXpKdtzl+Pf48LAy8PUaY3Q";
  systems = [ changwang-cw56-58 ];
in
{
  "openvpn-mullvad-userpass.age".publicKeys = users ++ systems;
  "openvpn-mullvad-ca.age".publicKeys = users ++ systems;
  "user-password.age".publicKeys = systems;
}
