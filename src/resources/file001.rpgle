dcl-s name char(10) inz('John Doe');
dcl-s age  zoned(2) inz(32);
dcl-ds user_data qualified;
    city char(20);
    country char(20);
    phone zoned(10);
    cellphone zoned(10);
end-ds;

dsply name;
user_data.city = 'Viena';
user_data.country = 'Austria';
user_data.phone = 4459019;
user_data.cellphone = 7729972;
return;