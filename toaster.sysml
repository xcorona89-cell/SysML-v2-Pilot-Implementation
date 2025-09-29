package hello::toaster {
  import kernel::*;
  import standard::*;

  // ---- Interfaces (flows) ----
  interface def ElectricalPower { in supply: Real; out return: Real; }
  interface def ControlSignal   { in cmd: String;  out state: String; }
  interface def ThermalFlow     { out heat: Real; }
  interface def UserAction      { out action: String; }
  interface def MaterialFlow    { out crumbs: Real; }

  // ---- Parts ----
  part def ACMains { port outPwr: ElectricalPower; }
  part def PowerCord { port inPwr: ElectricalPower; port outPwr: ElectricalPower; }
  part def FuseSafety { port inPwr: ElectricalPower; port outPwr: ElectricalPower; }

  part def ControlUnit {
    port inPwr: ElectricalPower;
    port toHeater: ElectricalPower;    // switched power
    port fromUser: UserAction;
    port fromTimer: ControlSignal;     // set time
    port fromThermo: ControlSignal;    // temperature feedback
    port toEject: ControlSignal;       // release
    attr toastTime: Duration;
  }

  part def TimerDial { port toCtrl: ControlSignal; }
  part def LeverLatch { port toCtrl: ControlSignal; port fromEject: ControlSignal; }
  part def EjectMechanism { port fromCtrl: ControlSignal; port toLever: ControlSignal; }
  part def Thermostat { port toCtrl: ControlSignal; }
  part def HeatingElement { port inPwr: ElectricalPower; port outHeat: ThermalFlow; }
  part def BreadSlots { port fromHeat: ThermalFlow; port toCrumbs: MaterialFlow; }
  part def CrumbTray { port fromSlots: MaterialFlow; }
  part def Casing { }
  part def User { port actions: UserAction; }

  // ---- Assembly ----
  part def Toaster {
    part mains: ACMains;
    part cord: PowerCord;
    part fuse: FuseSafety;
    part control: ControlUnit;
    part timer: TimerDial;
    part lever: LeverLatch;
    part eject: EjectMechanism;
    part thermo: Thermostat;
    part heater: HeatingElement;
    part slots: BreadSlots;
    part crumbs: CrumbTray;
    part casing: Casing;
    part user: User;

    // power path
    connect mains.outPwr     -> cord.inPwr;
    connect cord.outPwr      -> fuse.inPwr;
    connect fuse.outPwr      -> control.inPwr;
    connect control.toHeater -> heater.inPwr;

    // user + controls
    connect user.actions -> lever.toCtrl;     // push
    connect user.actions -> timer.toCtrl;     // set time
    connect timer.toCtrl -> control.fromTimer;
    connect lever.toCtrl -> control.fromUser;

    // feedback + eject
    connect thermo.toCtrl   -> control.fromThermo;
    connect control.toEject -> eject.fromCtrl;
    connect eject.toLever   -> lever.fromEject;

    // heat + crumbs
    connect heater.outHeat -> slots.fromHeat;
    connect slots.toCrumbs -> crumbs.fromSlots;
  }

  // small instance so tools can render quickly
  part toasterSys: Toaster;
}
