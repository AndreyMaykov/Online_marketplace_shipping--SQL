
# Online Marketplace Shipping Schema Project

The schema mentioned in the title was created as part of a major project aimed at building from scratch some online marketplace (I’ll be referring to this particular online marketplace as just **OM**). 

## Contents
[On the entire OM database](#EntireDB) <br /> 
[OM shipping process features and their implementation in the schema](#Shipping_features) <br />
[Stage A: Determining employee and vehicle availability. OM Shipping schema](#Determining_availability) <br />
  [How the data is organized into tables](#Data_in_tables) <br />
  [Constraints and triggers](#Constraints) <br />
  [Calculating availability intervals for a wave](#Calculating_intervals) <br />
[Stage B: Dispatching orders and vehicles among employees and preparing shipment assignments](#Stage_B) <br />
[Acknowledgements](#Acknowledgements) <br />

<a name = "EntireDB"><h2>On the entire OM database</h2></a>

The OM system architecture includes a 3NF database (MySQL). Not only does this DB store all the information about OM's customers and their orders as well as sellers and their products, but it is used for planning shipping operations. 
The following diagram shows the DB’s conceptual data model:

![ ](https://github.com/AndreiMaikov/MVM_Shipping--SQL/blob/main/images/OM_Full.svg)

Tables in the diagram are grouped accordingly to the type of information they hold – whether it is related to customers, products, etc. The Common group includes a three-table structure **users&nbsp;&ndash;&nbsp;user_roles&nbsp;&ndash;&nbsp;roles**, which is worth elaborating on here.

A person involved in OM business processes can have more than one role. For example, someone can act in one transaction as a buyer and in another as a seller, or the same employee can pick an order and deliver it as a driver. 

This results in many-to-many relationships between the **"users"** (actors of the OM business processes) and the **roles** available in such processes (which are Customer, Vendor, Administrator, Picker and Driver). To resolve these many-to-many relationships in compliance with the third normal form requirements, the table structure users&nbsp;&ndash;&nbsp;user_roles&nbsp;&ndash;&nbsp;roles is utilized. Each row of the user_roles table corresponds to a user and one of the user’s roles.

The structure of the Shipping table group and the reasons why this structure was chosen are discussed in the following sections.


<a name = "Shipping_features"><h2>OM shipping process features and their implementation in the schema</h2></a>

The Shipping tables were designed to suit the following characteristics of the OM shipping process:

- All OM’s shipping operations are both planned and carried out by the company’s employees; the vehicles used for shipping are owned or leased by the company.
- Order pickers and drivers (and, if there are any, employees who do both jobs) must be provided with shipment assignments specifying the orders they need to assemble/deliver, the related locations and  completion times, etc.
- It is required that the shipping process is organized in so-called **"waves"**. A wave consists of a time interval established by the OM management and a set of shipping assignments that are to be started and finished during this interval. No waves as well as one or more waves can be planned for one day (e.g., 10&nbsp;am&nbsp;&ndash;&nbsp;2&nbsp;pm and 3&nbsp;pm&nbsp;&ndash;&nbsp;7&nbsp;pm).

Wave planning can be done in two stages: <br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**(A)**&nbsp;&nbsp;determining which employees and vehicles are available for the wave, and <br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**(B)**&nbsp;&nbsp;assigning vehicles to drivers, dispatching  orders to pickers and drivers, and preparing shipment assignments for them.
    
    

<a name = "Determining_availability"><h2>Stage A: Determining employee and vehicle availability. OM Shipping schema</h2></a>

These tasks define the structure of the Shipping section [of the OM database]. The Shipping tables can be designed within a smaller schema &mdash; the **OM Shipping schema**&nbsp;&mdash; which includes only them and the users&nbsp;&ndash;&nbsp;user_roles&nbsp;&ndash;&nbsp;roles group of the Common section; in other words,
<p align = "center">
   OM Shipping schema&nbsp;&nbsp;=&nbsp;&nbsp;[&nbsp;Shipping tables from the OM schema&nbsp;] 
	+ [&nbsp;users&nbsp;&ndash;&nbsp;user_roles&nbsp;&ndash;&nbsp;roles tables&nbsp;] .
</p>

The following diagram shows the OM Shipping schema along with the Stage A and B data flows in the OM system (for the code, see
<a href="https://github.com/AndreiMaikov/MVM_Shipping--SQL/tree/main/src/OM_Shipping_schema.sql">OM_Shipping_schema.sql</a>).
To integrate the Shipping tables developed this way into the entire OM schema, one only needs to add them to the rest of the tables: no references between the Shipping tables and the tables in the Customers, Vendors, Products, and Orders sections are required.



<a name = "OM_Shipping diagram">
	
![ ](https://github.com/AndreiMaikov/MVM_Shipping--SQL/blob/main/images/OM_Shipping_0.5.svg)
	
</a>

The five tables used for determining employee and vehicle availability are:
- wave_timings;
- staff_regular_availability;
- blocked_periods;
- vehicles;
- vehicles_out_of_service.

After the availability is calculated (see <a href="#Calculating_intervals">below</a>), the results are placed into another two tables:
- wave_available_staff
- wave_available_vehicles

<a name = "Data_in_tables"><h3>How the data is organized into tables</h3></a>

The **wave_timings** table contains the beginning and ending times of each wave.

The **staff_regular_availability** table stores each employee’s individual weekly schedule (which can be different for different employees).  The following is supported:
- the availability of the employee can vary from day to day during the week;
- within a day, the employee can be available for one or more intervals, or not available at all.

The **blocked_periods** table contains information regarding planned periods when each user will be unavailable, 
	such as vacations, leaves for medical reasons, 
	holidays specific to religious or cultural traditions, etc.
	Each user can have an arbitrary number (including zero) of blocked periods.
	
The **vehicles** table stores comprehensive information on the vehicles the company uses for shipping. This information is mostly used in Stage B or for administrative purposes; in Stage A, the table is only used as a list of the delivery vehicles owned or leased by the company, with their lease terms if applicable.

For each vehicle, the **vehicles_not_in_service** table provides the beginning and ending times of the planned periods when the vehicle cannot be used for shipping due to any reason – e.g., being in repairs or employed for another service. 

Within each wave and for employee, the table **wave_available_staff** lists all the time intervals that the employee is available for (during the entire interval). The **wave_available_vehicles** table provides the same information about the vehicles.

**Note.**&nbsp;&nbsp;For some of the tables, only part of their columns are shown in the diagram if this does not matter for the problems discussed in the next sections (for example, it does not affect wave planning the `users` table contains the column holding the dates the users were registered in the system).


<a name = "Constraints"><h3>Constraints and triggers</h3></a>

A number of constraints are added to the Shipping tables.

- UNIQUE and CHECK constraints are used to prevent some possible data entry mistakes (such as associating one user id with more than one picker ids, or a blocked period’s beginning time being later than its ending time). 

- ON DELETE CASCADE and ON UPDATE CASCADE subclauses are defined to enforce data integrity where appropriate; otherwise, triggers are used for that.

For details, please see the code and comments in
<a href="https://github.com/AndreiMaikov/MVM_Shipping--SQL/tree/main/src/OM_Shipping_schema.sql">OM_Shipping_schema.sql</a> 
and 
<a href="https://github.com/AndreiMaikov/MVM_Shipping--SQL/tree/main/src/OM_Shipping_triggers.sql">OM_Shipping_triggers.sql</a>).


<a name = "Calculating_intervals"><h3>Calculating availability for a wave</h3></a>

Speaking mathematically, the problem of determining an employee’s availability for a given wave is essentially a problem of finding the intersection between two sets: the wave’s time interval and the union of all the time intervals when the employee is available (taking into account the employee’s regular availability and blocked periods). To solve this problem, one has to do some manipulations with inequalities that define the time intervals involved. The same is true of determining vehicle availability.

Such calculations can be performed either at the database level or at the application level of the system (see 
<a href = "#OM_Shipping diagram">the diagram</a>).

Each of these options has its advantages and drawbacks. Choosing between them needs weighing such factors as the convenience of implementation and maintenance as well as the effect on the performance of the specific system in question. A database-level solution based on DB stored procedures is discussed in <a href="https://github.com/AndreiMaikov/Shipping_resources_availability--SQL">Shipping Resources Availability Project</a>.

<a name = "Stage_B"><h2>Stage B: Dispatching orders and vehicles among employees and preparing shipment assignments</h2></a>

This problem is considerably more complex than determining employee and vehicle availability. For example, it may need taking into account the maximum cargo weight and volume each available vehicle can carry and the weight and volume of the orders dispatched for shipping, or optimal routing considerations, or how much an employee can lift, or even pickers’ ability to do gift packing. 

Due to the complexity of the problem, it would be ineffective to try to implement any suitable solving algorithm completely at the database level&nbsp;&mdash;
it should be done at the application level. However, utilizing some stored procedures can be useful in Stage B.

As <a href = "#OM_Shipping diagram">the diagram</a> shows, information required for Stage B and related to the employees’ and the vehicles’ capabilities is stored in the picker_profiles, driver_profiles, and vehicles tables. Data related to the products' weights and sizes and the orders' contents are stored in the Products and Orders sections of the database, and the information for routing can be retrieved from the Customers and Vendors sections as well as the addresses table. All this, along with the data held in the wave_timings, wave_available_staff, and wave_available_vehicles tables, provides for successful completion of Stage B at the OM system's application level.

<a name="Acknowledgements"><h2>Acknowledgements</h2></a>

I would like to thank Alek Mlynek for initiating this project as well as discussing it in depth and in detail.

