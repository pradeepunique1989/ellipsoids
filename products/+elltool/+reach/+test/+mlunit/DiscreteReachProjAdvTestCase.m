classdef DiscreteReachProjAdvTestCase < ...
        elltool.reach.test.mlunit.AReachProjAdvTestCase
    methods
        function self = DiscreteReachProjAdvTestCase(varargin)
            self = self@elltool.reach.test.mlunit.AReachProjAdvTestCase(...
                elltool.linsys.LinSysDiscreteFactory(), ...
                elltool.reach.ReachDiscreteFactory(), ...
                varargin{:});
        end
    end
end