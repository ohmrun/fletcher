package eu.ohmrun.fletcher;

typedef ContApi<P,R>            = eu.ohmrun.fletcher.core.Cont.ContApi<P,R>;
typedef ContCls<P,R>            = eu.ohmrun.fletcher.core.Cont.ContCls<P,R>;
typedef Cont<P,R>               = eu.ohmrun.fletcher.core.Cont<P,R>;

typedef SettleApi<P>            = eu.ohmrun.fletcher.core.Settle.SettleApi<P>;
typedef SettleCls<P>            = eu.ohmrun.fletcher.core.Settle.SettleCls<P>;
typedef Settle<P>               = eu.ohmrun.fletcher.core.Settle<P>;

typedef Context<P,R,E>          = eu.ohmrun.fletcher.core.Context<P,R,E>;
typedef ContextCls<P,R,E>       = eu.ohmrun.fletcher.core.ContextCls<P,R,E>;


typedef ReceiverCls<P,R>        = eu.ohmrun.fletcher.core.Receiver.ReceiverCls<P,R>;
typedef ReceiverApi<P,R>        = eu.ohmrun.fletcher.core.Receiver.ReceiverApi<P,R>;
typedef ReceiverDef<P,R>        = eu.ohmrun.fletcher.core.Receiver.ReceiverDef<P,R>;
typedef Receiver<P,R>           = eu.ohmrun.fletcher.core.Receiver.Receiver<P,R>;

typedef ReceiverInput<R,E>      = eu.ohmrun.fletcher.core.ReceiverInput<R,E>;
typedef ReceiverInputDef<R,E>   = eu.ohmrun.fletcher.core.ReceiverInput.ReceiverInputDef<R,E>;


typedef ReceiverSinkApi<R,E>    = eu.ohmrun.fletcher.core.ReceiverSink.ReceiverSinkApi<R,E>;
typedef ReceiverSinkCls<R,E>    = eu.ohmrun.fletcher.core.ReceiverSink.ReceiverSinkCls<R,E>;
typedef ReceiverSinkAbs<R,E>    = eu.ohmrun.fletcher.core.ReceiverSink.ReceiverSinkAbs<R,E>;
typedef ReceiverSink<R,E>       = eu.ohmrun.fletcher.core.ReceiverSink<R,E>;


typedef TerminalAbs<R,E>        = eu.ohmrun.fletcher.core.Terminal.TerminalAbs<R,E>;
typedef TerminalApi<R,E>        = eu.ohmrun.fletcher.core.Terminal.TerminalApi<R,E>;
typedef TerminalCls<R,E>        = eu.ohmrun.fletcher.core.Terminal.TerminalCls<R,E>;
typedef Terminal<R,E>           = eu.ohmrun.fletcher.core.Terminal<R,E>;

typedef TerminalInputDef<R,E>   = eu.ohmrun.fletcher.core.TerminalInput.TerminalInputDef<R,E>;
typedef TerminalInput<R,E>      = eu.ohmrun.fletcher.core.TerminalInput<R,E>;

typedef TerminalSinkDef<R,E>    = eu.ohmrun.fletcher.core.TerminalSink.TerminalSinkDef<R,E>;
typedef TerminalSink<R,E>       = eu.ohmrun.fletcher.core.TerminalSink<R,E>;
typedef Waypoint<R,E>           = Terminal<Upshot<R,E>,Nada>;