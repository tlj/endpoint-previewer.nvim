### Endpoint Previewer 

### Things to add

- [x] Set package to empty by default and ask for package on first run 
- [x] Configure a list of base URLs, and add a selector to change the default
- [x] Remove the base url from the history, so it's easier to swap between same recent endpoint with different base urls. For example to open one window with local dev, one with master, and then compare them
- [x] Open a buffer immediately with a message saying "downloading <url>...", then overwrite that with the content
- [x] Async loading of endpoints to unblock UI and enable usage of debuger
- [x] Make a method for opening an endpoint from two base urls at the same time, opening in two windows
- [ ] Add support for API keys
- [ ] Document endpoints.json format, use one endpoint for all APIs
- [ ] Support multiselect through `get_current_picker(buf):get_multi_selection()`. Open all endpoints (up to a limit)

