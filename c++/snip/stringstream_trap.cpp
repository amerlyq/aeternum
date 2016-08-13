// Note: This article was originally written in Chinese by Ke Wen Lin/China/IBM. I translated this article into English.

Strings are frequently used in C++ programs. C++ Standard Library provides the <string> and <sstream> libraries, which are very useful for string manipulations, such as object encapsulation, safe and automatic type conversion, direct concatenation, and bound exceed avoidance. This article will discover a trap when using stringstream.str(). Here is an example:

Example 1:

     1  #include <string>
     2  #include <sstream>
     3  #include <iostream>
     4
     5  using namespace std;
     6
     7  int main()
     8  {
     9      stringstream ss("012345678901234567890123456789012345678901234567890123456789");
    10      stringstream t_ss("abcdefghijklmnopqrstuvwxyz");
    11      string str1(ss.str());
    12
    13      const char* cstr1 = str1.c_str();
    14      const char* cstr2 = ss.str().c_str();
    15      const char* cstr3 = ss.str().c_str();
    16      const char* cstr4 = ss.str().c_str();
    17      const char* t_cstr = t_ss.str().c_str();
    18
    19      cout << "------ The results ----------" << endl
    20           << "cstr1:\t" << cstr1 << endl
    21           << "cstr2:\t" << cstr2 << endl
    22           << "cstr3:\t" << cstr3 << endl
    23           << "cstr4:\t" << cstr4 << endl
    24           << "t_cstr:\t" << t_cstr << endl
    25           << "-----------------------------"  << endl;
    26
    27      return 0;
    28  }

The output is:

        ------ The results ----------
        cstr1:  012345678901234567890123456789012345678901234567890123456789
        cstr2:  012345678901234567890123456789012345678901234567890123456789
        cstr3:  abcdefghijklmnopqrstuvwxyz
        cstr4:  abcdefghijklmnopqrstuvwxyz
        t_cstr: abcdefghijklmnopqrstuvwxyz
        -----------------------------

From the output, we can surprisingly see that values of cstr3 and cstr4 are not the same as that of string ss, but equal to the value of t_ss. Let's add several statements in example 1 to find out why this happens.

Example 2:

     1  #include <string>
     2  #include <sstream>
     3  #include <iostream>
     4
     5  using namespace std;
     6
     7  #define PRINT_CSTR(no) printf("cstr" #no " addr:\t%p\n",cstr##no)
     8  #define PRINT_T_CSTR(no) printf("t_cstr" #no " addr:\t%p\n",t_cstr##no)
     9
    10  int main()
    11  {
    12      stringstream ss("012345678901234567890123456789012345678901234567890123456789");
    13      stringstream t_ss("abcdefghijklmnopqrstuvwxyz");
    14      string str1(ss.str());
    15
    16      const char* cstr1 = str1.c_str();
    17      const char* cstr2 = ss.str().c_str();
    18      const char* cstr3 = ss.str().c_str();
    19      const char* cstr4 = ss.str().c_str();
    20      const char* t_cstr = t_ss.str().c_str();
    21
    22      cout << "------ The results ----------" << endl
    23           << "cstr1:\t" << cstr1 << endl
    24           << "cstr2:\t" << cstr2 << endl
    25           << "cstr3:\t" << cstr3 << endl
    26           << "cstr4:\t" << cstr4 << endl
    27           << "t_cstr:\t" << t_cstr << endl
    28           << "-----------------------------"  << endl;
    29      printf("\n------ Char pointers ----------\n");
    30      PRINT_CSTR(1);
    31      PRINT_CSTR(2);
    32      PRINT_CSTR(3);
    33      PRINT_CSTR(4);
    34      PRINT_T_CSTR();
    35
    36      return 0;
    37  }

In example 2, the addresses of the strings are printed out. The output is:

        ------ The results ----------
        cstr1:  012345678901234567890123456789012345678901234567890123456789
        cstr2:  012345678901234567890123456789012345678901234567890123456789
        cstr3:  abcdefghijklmnopqrstuvwxyz
        cstr4:  abcdefghijklmnopqrstuvwxyz
        t_cstr: abcdefghijklmnopqrstuvwxyz
        -----------------------------

        ------ Char pointers ----------
        cstr1 addr:     0x100200e4
        cstr2 addr:     0x10020134
        cstr3 addr:     0x10020014
        cstr4 addr:     0x10020014
        t_cstr addr:    0x10020014


From the output, we can see that the addresses of cstr3 , cstr4 and t_cstr are the same, which explains why their values are the same as shown in the output. Usually we might assume that when ss.str() is called in line 17~19, three string objects will be created and each object has a different address.

However the output shows otherwise. In fact, when streamstring calls str(), it returns a temporary string object, which will be destructed along with the function return. Then c_str() is called right after str() and the argument passed into c_str() is a corresponding C string of the temporary string object. Thus, these strings cannot be referenced after the expression evaluation, and the memory will be retrieved or might be overwritten. Although in some cases (for example, delete line 20 from example 2), this memory might not be overwritten and we can still read out the strings, but the accuracy of the read result is not guaranteed.

Let's modify example 2 as below:

Example 3：
     1  #include <string>
     2  #include <sstream>
     3  #include <iostream>
     4
     5  using namespace std;
     6
     7  #define PRINT_CSTR(no) printf("cstr" #no " addr:\t%p\n",cstr##no)
     8  #define PRINT_T_CSTR(no) printf("t_cstr" #no " addr:\t%p\n",t_cstr##no)
     9
    10  int main()
    11  {
    12      stringstream ss("012345678901234567890123456789012345678901234567890123456789");
    13      stringstream t_ss("abcdefghijklmnopqrstuvwxyz");
    14      string str1(ss.str());
    15
    16      const char* cstr1 = str1.c_str();
    17      const string& str2 = ss.str();
    18      const char* cstr2 = str2.c_str();
    19      const string& str3 = ss.str();
    20      const char* cstr3 = str3.c_str();
    21      const string& str4 = ss.str();
    22      const char* cstr4 = str4.c_str();
    23      const char* t_cstr = t_ss.str().c_str();
    24
    25      cout << "------ The results ----------" << endl
    26           << "cstr1:\t" << cstr1 << endl
    27           << "cstr2:\t" << cstr2 << endl
    28           << "cstr3:\t" << cstr3 << endl
    29           << "cstr4:\t" << cstr4 << endl
    30           << "t_cstr:\t" << t_cstr << endl
    31           << "-----------------------------"  << endl;
    32      printf("\n------ Char pointers ----------\n");
    33      PRINT_CSTR(1);
    34      PRINT_CSTR(2);
    35      PRINT_CSTR(3);
    36      PRINT_CSTR(4);
    37      PRINT_T_CSTR();
    38
    39      return 0;
    40  }


        The output is:

        ------ The results ----------
        cstr1:  012345678901234567890123456789012345678901234567890123456789
        cstr2:  012345678901234567890123456789012345678901234567890123456789
        cstr3:  012345678901234567890123456789012345678901234567890123456789
        cstr4:  012345678901234567890123456789012345678901234567890123456789
        t_cstr: abcdefghijklmnopqrstuvwxyz
        -----------------------------

        ------ Char pointers ----------
        cstr1 addr:     0x100200e4
        cstr2 addr:     0x10020134
        cstr3 addr:     0x10020184
        cstr4 addr:     0x100201d4
        t_cstr addr:    0x10020014


From the examples, we know that stringstream.str() will return a temporary string object, which will be destroyed after the function call. When we want to manipulate on this string object (for example, to create corresponding C string), we must be very careful about this trap that might cause unexpected results.

Since the memory of the temporary object might not be overwritten so that this trap might not expose, but the usage does not guarantee the accuracy of the results. So to avoid wrong results, you should make sure to use this function correctly.

// System and compiler environment:
//  Red Hat Enterprise Linux Server release 5.8 (Tikanga)
//  Linux 2.6.18-308.el5 ppc64 GNU/Linux
//  gcc version 4.1.2 20080704 (Red Hat 4.1.2-52)
