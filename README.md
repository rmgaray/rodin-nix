# rodin-nix

This a simple FHS wrapper over the Rodin official binary package. You can run
Rodin with:

```
nix run github:rmgaray/rodin-nix
```

You may use the Rodin's "Install software" feature to install any plugins you
like. I've had no issues so far with all the plugins I installed (ProB,
State Machines, AtelierB provers, etc.)

The plugins will be installed in your user's home directory, so you can expect
the installations to persist between program invocations. The same goes for any
changes you make to the workspace.

## TODO

* [ ] Provide more versions of Rodin
* [ ] Make the plugins installation declarative
* [ ] Make the workspace configuration declarative? (This might not be very useful).
