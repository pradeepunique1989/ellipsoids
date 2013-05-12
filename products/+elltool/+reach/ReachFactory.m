classdef ReachFactory < handle
    properties (Access = private)
        confName
        crm
        crmSys
        linSys
        l0Mat
        x0Ell
        tVec
        isBack
        isEvolve
        isDiscr
        dim
        reachObjMap
    end
    methods
        function self =...
                ReachFactory(confName, crm, crmSys, isBack, isEvolve,...
                isDiscr)
            % Example:
            %   import elltool.reach.ReachFactory;
            %   crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            %   crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            %   rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
            %
            if nargin < 6
                isDiscr = false;
            end
            
            self.confName = confName;
            self.crm = crm;
            self.crmSys = crmSys;
            self.isBack = isBack;
            self.isEvolve = isEvolve;
            self.isDiscr = isDiscr;
            %
            crm.deployConfTemplate(confName);
            crm.selectConf(confName);
            sysDefConfName = crm.getParam('systemDefinitionConfName');
            crmSys.selectConf(sysDefConfName, 'reloadIfSelected', false);
            %
            self.dim = crmSys.getParam('dim');
            atDefCMat = crmSys.getParam('At');
            btDefCMat = crmSys.getParam('Bt');
            ctDefCMat = crmSys.getParam('Ct');
            ptDefCMat = crmSys.getParam('control_restriction.Q');
            ptDefCVec = crmSys.getParam('control_restriction.a');
            qtDefCMat = crmSys.getParam('disturbance_restriction.Q');
            qtDefCVec = crmSys.getParam('disturbance_restriction.a');
            x0DefMat = crmSys.getParam('initial_set.Q');
            x0DefVec = crmSys.getParam('initial_set.a');
            l0CMat = crm.getParam(...
                'goodDirSelection.methodProps.manual.lsGoodDirSets.set1');
            self.l0Mat = cell2mat(l0CMat.').';
            self.x0Ell = ellipsoid(x0DefVec, x0DefMat);
            self.tVec = [crmSys.getParam('time_interval.t0'),...
                crmSys.getParam('time_interval.t1')];
            if self.isBack
                self.tVec = [crmSys.getParam('time_interval.t1'),...
                    crmSys.getParam('time_interval.t0')];
            else
                self.tVec = [crmSys.getParam('time_interval.t0'),...
                    crmSys.getParam('time_interval.t1')];
            end
            ControlBounds = struct();
            ControlBounds.center = ptDefCVec;
            ControlBounds.shape = ptDefCMat;
            DistBounds = struct();
            DistBounds.center = qtDefCVec;
            DistBounds.shape = qtDefCMat;
            %
            if isDiscr
                self.linSys = elltool.linsys.LinSysDiscrete(atDefCMat, ...
                    btDefCMat,...
                    ControlBounds, ctDefCMat, DistBounds, [], [], 'd');
            else
                self.linSys = elltool.linsys.LinSysContinuous(atDefCMat, ...
                    btDefCMat,...
                    ControlBounds, ctDefCMat, DistBounds);
            end
            self.reachObjMap = containers.Map();
        end
        function reachObj = createInstance(self,varargin)
            % Example:
            %   import elltool.reach.ReachFactory;
            %   crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            %   crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            %   rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
            %   reachObj = rsObj.createInstance();
            %
            import modgen.common.parseparext;
            [reg, isRegSpec, linSysObj, x0EllMat, l0DirMat, timeVec] = ...
                parseparext(varargin, {'linSys','x0Ell', 'l0Mat','tVec';...
                self.linSys, self.x0Ell, self.l0Mat, self.tVec;...
                'isobject(x)','ismatrix(x)', 'ismatrix(x)','isvector(x)'});
            keyStr=hash(varargin);
            if ~self.reachObjMap.isKey(keyStr)
                if isa(linSysObj, 'elltool.linsys.LinSysDiscrete')
                    reachObj = elltool.reach.ReachDiscrete(linSysObj,...
                        x0EllMat, l0DirMat, timeVec);
                elseif self.isEvolve
                    halfReachObj = elltool.reach.ReachContinuous(...
                        linSysObj, x0EllMat, l0DirMat,...
                        [timeVec(1) sum(timeVec)/2]);
                    reachObj = halfReachObj.evolve(timeVec(2));
                else
                    reachObj = elltool.reach.ReachContinuous(...
                        linSysObj, x0EllMat, l0DirMat, timeVec);
                end
                self.reachObjMap(keyStr)=reachObj;
            else
                reachObj=self.reachObjMap(keyStr);
            end
        end
        function linSys = getLinSys(self)
            % Example:
            %   import elltool.reach.ReachFactory;
            %   crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            %   crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            %   rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
            %   linSys = rsObj.getLinSys();
            %
            linSys = self.linSys;
        end
        function dim = getDim(self)
            % Example:
            %   import elltool.reach.ReachFactory;
            %   crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            %   crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            %   rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
            %   dim = rsObj.getDim();
            %
            dim = self.dim;
        end
        function tVec = getTVec(self)
            % Example:
            %   import elltool.reach.ReachFactory;
            %   crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            %   crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            %   rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
            %   tVec = rsObj.getTVec()
            %
            %   tVec =
            %
            %        0    10
            %
            tVec = self.tVec;
        end
        function x0Ell = getX0Ell(self)
            % Example:
            %   import elltool.reach.ReachFactory;
            %   crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            %   crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            %   rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
            %   X0Ell = rsObj.getX0Ell()
            %
            %   X0Ell =
            %
            %   Center:
            %        0
            %        0
            %
            %   Shape Matrix:
            %       0.0100         0
            %            0    0.0100
            %
            %   Nondegenerate ellipsoid in R^2.
            %
            x0Ell = self.x0Ell;
        end
        function l0Mat = getL0Mat(self)
            % Example:
            %   import elltool.reach.ReachFactory;
            %   crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            %   crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            %   rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
            %   l0Mat = rsObj.getL0Mat()
            %
            %   l0Mat =
            %
            %        1     0
            %        0     1
            %
            l0Mat = self.l0Mat;
        end
    end
end