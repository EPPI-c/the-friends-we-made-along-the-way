local statemachine = {}

function statemachine:changestate(state, variable)
    self.state = state
    if self.state.changedstate then
        self.state:changedstate(variable)
    end
end

return statemachine
