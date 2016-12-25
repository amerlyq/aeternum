// ** Конвертирует в void*
template< typename method >
void* getPointer( method m )
{
  byte *pointer[ POINTER_SIZE ];
  memcpy( pointer, &m, POINTER_SIZE );
  return *( byte** )pointer;
}

// ** Ф-ция-переходник
template< class T, typename ret, typename arg0, ret ( T::*method )( arg0 ) >
ret thunk( void *object, arg0 _arg0 )
{
  return ((T*)object->*method)( _arg0 );
}

#define  virtualMethod1( c, r, m, arg0 ) getPointer( &GenThunk<c, r, arg0, &c::m> )

// ** Ну и на конец указатель, через который можно потом дернуть метод из асма
void *pointer = virtualMethod1( cSceneObject, void, SetTransform, const cMatrix4& );
