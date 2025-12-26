local statemachine = {}

function statemachine:changestate(state, ...)
    self.state = state
    if self.state.changedstate then
        self.state:changedstate(...)
    end
end

return statemachine
