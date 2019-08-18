/* RTTI
 * Для определения типа во время выполнения программы (run-time type
 * information) используется оператор typeid и класс type_info, определеный в
 * файле typeinfo или typeinfo.h. В качестве аргумента typeid принимает имя типа
 * или константную ссылку. В случае некорректного аргумента, например нулевой
 * указатель, возникает исключение bad_typeid.  В классе type_info определены
 * операции == и !=, и метод name, возвращающий имя типа назначаемого
 * компилятором (не имя используемое программистом). Объект данного класса можно
 * получить только оператором typeid.  Дополнительно в typeinfo определено
 * исключение bad_cast возникающее при не успешном преобразовании типов
 * оператором dynamic_cast.  Использование RTTI замедляет выполнение программы.
 * Поэтому в большинстве компиляторов предусмотрено управление использованием
 * RTTI с помощью ключей компиляции.
 */

#include <iostream>
#include <typeinfo>
using namespace std;

class A {
public:
    virtual void out() {
        cout<<"A"<<endl;
    }
} a, *ptr;

class B : public A {
public:
    void out() {
        cout<<"B"<<endl;
    }
} b;

class C : public A {
public:
    void out() {
        cout<<"C"<<endl;
    }
} c;

bool isB(const A*ptr){
return typeid(B)==typeid(*ptr);
}


int main() {
    ptr=&a;
    cout<<"isB for a: "<<isB(ptr)<<", real type: "<<typeid(*ptr).name()
    <<", check by virtual metod: ";ptr->out();cout<<endl;

    ptr=&b;
    cout<<"isB for b: "<<isB(ptr)<<", real type: "<<typeid(*ptr).name()
    <<", check by virtual metod: ";ptr->out();cout<<endl;

    ptr=&c;
    cout<<"isB for c: "<<isB(ptr)<<", real type: "<<typeid(*ptr).name()
    <<", check by virtual metod: ";ptr->out();cout<<endl;

    cout<<"again isB for c: "<<isB(&c)<<", real type: "<<typeid(c).name()
    <<endl;

    cout<<"int name="<<typeid(int).name()<<", double name="
    <<typeid(double).name()<<endl;

    return 0;
}
