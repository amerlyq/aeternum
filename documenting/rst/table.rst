```````````
reST Tables
```````````

GRID
####

.. table:: Rearrange app priorities

   +----------+---------+
   |Name      |Age      |
   +==========+=========+
   |Bill      |39       |
   +----------+---------+
   |Jane      |38       |
   +----------+---------+

+--------+-------------------------------+------------------------------------------------------------------+
| Status | Jira link / 2020-XX-YY @creds | Sub-Task Description (one line, short and SMART, under 1-3 days) |
+========+===============================+==================================================================+
| DONE   | 2019-12-06 @namesurname       | Resurrect old mail thread with followup                          |
+--------+-------------------------------+------------------------------------------------------------------+
| …      | ?                             | Find out priorities for all applications                         |
+--------+-------------------------------+------------------------------------------------------------------+
| …      | ?                             | Query how much time each app actually requires per each cycle    |
+--------+-------------------------------+------------------------------------------------------------------+
| …      | ?                             | Carefully rearrange priorities of normal and realtime tasks      |
|        |                               | -- hierarchy which can be preempted and in which situations      |
+--------+-------------------------------+------------------------------------------------------------------+
| …      | ?                             | Check scheduler starvation time of realtime and normal tasks     |
+--------+-------------------------------+------------------------------------------------------------------+


SIMPLE
######

.. table:: Rearrange app priorities
   :align: left
   :widths: auto

   ======  =============================  ===========================================================================================
   Status  Jira link / 2020-XX-YY @creds  Sub-Task Description (one line, short and SMART, under 1-3 days)
   ======  =============================  ===========================================================================================
   DONE    2019-12-06 @namesurname        Resurrect old mail thread with followup
   …       ?                              Find out priorities for all applications
   …       ?                              Query how much time each app actually requires per each cycle
   …       ?                              Carefully rearrange priorities of normal and real time tasks -- hierarchy which can be preempted and in which situations
   …       ?                              Check scheduler starvation time of realtime and normal tasks
   ======  =============================  ===========================================================================================


LIST
####

.. list-table:: Rearrange app priorities
   :widths: 15 10 30
   :header-rows: 1

   * - Status
     - Jira link / 2020-XX-YY @creds
     - Sub-Task Description (one line, short and SMART, under 1-3 days)

   * - DONE
     - 2019-12-06 @namesurname
     - Resurrect old mail thread with followup

   * - …
     - ?
     - Find out priorities for all applications

   * - …
     - ?
     - Query how much time each app actually requires per each cycle

   * - …
     - ?
     - Carefully rearrange priorities of normal and real time tasks --
       hierarchy which can be preempted and in which situations

   * - …
     - ?
     - Check scheduler starvation time of realtime and normal tasks


CVS
###

.. csv-table:: a title
   :header: "name", "firstname", "age"
   :widths: 20, 20, 10

   "Smith", "John", 40
   "Smith", "John, Junior", 20


LATEX
#####

.. tabularcolumns:: |l|c|p{5cm}|

+--------------+---+-----------+
|  simple text | 2 | 3         |
+--------------+---+-----------+
