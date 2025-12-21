local Events = {
  listeners = {}
}

function Events.on(name, fn)
  Events.listeners[name] = Events.listeners[name] or {}
  table.insert(Events.listeners[name], fn)
end

function Events.emit(name, ...)
  local list = Events.listeners[name]
  if not list then return end

  for _, fn in ipairs(list) do
    fn(...)
  end
end

return Events
