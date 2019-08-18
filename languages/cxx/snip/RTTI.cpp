/* RTTI
 * ��� ����������� ���� �� ����� ���������� ��������� (run-time type
 * information) ������������ �������� typeid � ����� type_info, ����������� �
 * ����� typeinfo ��� typeinfo.h. � �������� ��������� typeid ��������� ��� ����
 * ��� ����������� ������. � ������ ������������� ���������, �������� �������
 * ���������, ��������� ���������� bad_typeid.  � ������ type_info ����������
 * �������� == � !=, � ����� name, ������������ ��� ���� ������������
 * ������������ (�� ��� ������������ �������������). ������ ������� ������ �����
 * �������� ������ ���������� typeid.  ������������� � typeinfo ����������
 * ���������� bad_cast ����������� ��� �� �������� �������������� �����
 * ���������� dynamic_cast.  ������������� RTTI ��������� ���������� ���������.
 * ������� � ����������� ������������ ������������� ���������� ��������������
 * RTTI � ������� ������ ����������.
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
