import 'package:lua_dardo/lua.dart';

import '../binchunk/binary_chunk.dart';
import 'upvalue_holder.dart';

enum ClosureType {
  lua,
  dart
}

abstract class Closure<T> {

  final Prototype proto;
  final List<UpvalueHolder?> upvals;

  Closure(this.proto, this.upvals);

  T get body;
  ClosureType get type;

  int get nRegs => 0;
  int get nParams => 0;
  bool get isVararg => false;

  int execute(LuaState state) => -1;
  Future<int> executeAndWait(LuaState state) => Future.value(-1);

}

class LuaClosure extends Closure<Prototype> {

  LuaClosure(Prototype proto) : super(proto, List.filled(proto.upvalues.length, null));

  Prototype get body => proto;
  ClosureType get type => ClosureType.lua;

  int get nRegs => proto.maxStackSize;
  int get nParams => proto.numParams!;
  bool get isVararg => proto.isVararg == 1;

}

class DartClosure extends Closure<DartFunction?> {

  final DartFunction? dartFunc;

  DartClosure(this.dartFunc, int nUpvals) : super(Prototype(), List.filled(nUpvals, null));

  DartFunction? get body => dartFunc;
  ClosureType get type => ClosureType.dart;

  int execute(LuaState state) => dartFunc?.call(state) ?? -1;

}
