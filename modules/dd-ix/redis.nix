{ pkgs, ... }:

{
  services.redis.package = pkgs.valkey;
}
