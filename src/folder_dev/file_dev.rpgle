       CTL-OPT nomain alwnull(*usrctl) option(*srcstmt) datfmt(*iso)
       Copyright('AZ7 - Copyright CLAI Paytments Technologies.(C) Since 1993.');
       //-----------------------------------------------------------------*
       // AZ7 - Copyright CLAI Paytments Technologies.(C) Since 2024.
       //-----------------------------------------------------------------*
       // AI7 - Dashboard: Case listing and management
       //-----------------------------------------------------------------*
       // Seq.  Engineer                             Date        Draft
       // CL00  Albeiro Javier Lozano                2024-12-04  Q1090
       //-----------------------------------------------------------------*
       //-----------------------------------------------------------------*
       // file definitions
       //-----------------------------------------------------------------*
       dcl-f ACFCSL0 keyed rename(racfcs:racfcs0) usage(*output:*delete);
       dcl-f ACFCSL1 keyed rename(racfcs:racfcs1) usage(*output:*delete);
       dcl-f ACFSTL2 keyed usage(*output:*delete);
       dcl-f ACFTPL0 keyed usage(*output:*delete) rename(racftp:racftp0);
       dcl-f AZLHT   keyed;
       dcl-f AUUSR   keyed;
       dcl-f AUPFNL1 keyed;
       dcl-f AZPRM   keyed;
       dcl-f APPAIL1 keyed;
       dcl-f AZLER   keyed;
       //-----------------------------------------------------------------*
       // copies
       //-----------------------------------------------------------------*
       /COPY *LIBL/QTXTSRC,AY0405
       /COPY *LIBL/QTXTSRC,AY4565
       //-----------------------------------------------------------------*
       // work-fields definitions
       //-----------------------------------------------------------------*
       exec sql set option datfmt = *iso;
       dcl-c  CLOSURE_STATUS const('4');
       dcl-s  main ind inz(*off);
       dcl-s  default_st timestamp inz(*loval);
       dcl-s  current_user char(10) inz(*blanks);
       //-----------------------------------------------------------------*
       // ds definitions
       //-----------------------------------------------------------------*
       dcl-ds AZCFG dtaara len(100);
         v_site char(1) pos(19);
       end-ds;
       //-----------------------------------------------------------------*
       // External program definitions
       //-----------------------------------------------------------------*
       dcl-pr AZ1804 extpgm;
         *n char(21);//token
         *n char(21);//masked
         *n char(2); //res
       end-pr;

       dcl-pr AZ1802 extpgm;
         *n char(21);//pan
         *n char(21);//token
         *n char(2); //res
       end-pr;
       //-----------------------------------------------------------------*
       // Public procedure ++++++++++++++++++++++++++++++++++++++++++++++ *
       //-----------------------------------------------------------------*
       //-----------------------------------------------------------------*
       // Auth handler
        // Description procedure: check user permissions
        // Parameters:
        // @p_code_function: function code
        //    1: dashboard main
        //    2: assign
        //    3: scale
        //    4: close
        //    5: check all records or only user
        //    6: read subfile trx
        //    7: details trx
        //    8: add trx
        //    9: get list analyst
        // @p_forced_auth: force check auth even if main already checked
       //-----------------------------------------------------------------*
       dcl-proc $ai0405_auth_handler export;
         dcl-ds res likeds(ds_ai0405_auth_res);
         dcl-c RES_AUTH_OK const('S');// OK = S or NOT OK = N
         dcl-s aux_allowed char(1) inz('N');
         dcl-s v_forced_auth ind inz(*off);
         dcl-pi *n likeds(res);
           p_code_function zoned(2) const;
           p_forced_auth   ind options(*nopass) const;
         end-pi;

         dcl-pr AZ0315 extpgm;
           p_mod char(10) const;
           p_fun char(10) const;
           p_res char(1);
         end-pr;

         if %parms < %parmnum(p_forced_auth);
           v_forced_auth = *off;
         else;
           v_forced_auth = p_forced_auth;
         endif;

         res.module = 'AUTHORIZER';
         select;
         when p_code_function = 1;
           res.function = 'AM0405ENT';//dashboard main
           if not main or v_forced_auth;
             AZ0315(res.module:res.function:aux_allowed);
             main = aux_allowed = RES_AUTH_OK;
           endif;
         when p_code_function = 2;//assign
           res.function = 'AM0405ASG';
           AZ0315(res.module:res.function:aux_allowed);
         when p_code_function = 3;//scale
           res.function = 'AM0405ESC';
           AZ0315(res.module:res.function:aux_allowed);
         when p_code_function = 4;//close
           res.function = 'AM0405CLO';
           AZ0315(res.module:res.function:aux_allowed);
         when p_code_function = 5;//check all records or only user
           res.function = 'AM0405ACS';
           AZ0315(res.module:res.function:aux_allowed);
         when p_code_function = 6;//read subfile trx
           res.function = 'AM0405LST';
           AZ0315(res.module:res.function:aux_allowed);
         when p_code_function = 7;//details trx
           res.function = 'AM0405DET';
           AZ0315(res.module:res.function:aux_allowed);
         when p_code_function = 8;//add trx
           res.function = 'AM0405ADD';
           AZ0315(res.module:res.function:aux_allowed);
         when p_code_function = 9;//get list analyst
           res.function = 'AM0405SLA';
           AZ0315(res.module:res.function:aux_allowed);
         endsl;
         res.allowed = aux_allowed = RES_AUTH_OK;
         return res;
       end-proc;
       //-----------------------------------------------------------------*
        // Read subfile cases
        //Description procedure: read cases with filters
        // Parameters:
        // @p_fcskey: case number
        // @p_fcsint: card number
        // @p_fcssts: case status
        // @p_fstanl: assigned analyst
        // @p_fstini: initial date
        // @p_fstend: end date
        // @pointer_proc: pointer to callback procedure for each record
       //-----------------------------------------------------------------*
       dcl-proc $ai0405_read_cases export;
         dcl-ds res            likeds(ds_ai0405_auth_res);
         dcl-ds res_only_user  likeds(ds_ai0405_auth_res);
         dcl-ds res_general_pt likeds(ds_ai0405_general_data_pt);
         dcl-s  super_user     zoned(1) inz(0);
         dcl-ds data ext inz(*extdft) extname('ACFCS') qualified;
           FSTINI timestamp;
           FSTANL char(10);
         end-ds;
         dcl-ds data_rec likeds(ds_ai0405_reads);
         dcl-pi *n likeds(res);
           p_fcskey packed(6) const;
           p_fcsint char(21)  const;
           p_fcssts char(1)   const;
           p_fstanl char(10)  const;
           p_fstini timestamp const;
           p_fstend timestamp const;
           pointer_proc pointer(*proc) const;
         end-pi;
         dcl-pr cb_proc extproc(pointer_proc);
           *n pointer const;
         end-pr;

         res = $ai0405_auth_handler(1);
         current_user = wu_psds.PSDSUSRPRF;
         if res.allowed;
           res_only_user = $ai0405_auth_handler(5);
           if res_only_user.allowed;
             super_user = 1;
           endif;

           EXEC SQL DECLARE LIST_CASES CURSOR FOR

           WITH LAST_STS AS (
           SELECT FSTFCS, FSTINT, FSTINI, FSTANL,
           ROW_NUMBER() OVER (PARTITION BY FSTFCS, FSTINT ORDER BY FSTINI DESC)
           AS RN
           FROM ACFST WHERE (:SUPER_USER = 1 OR FSTANL = :CURRENT_USER)
           )
           SELECT FCSKEY, FCSINT, FCSSTS, FCSCRD, FCSFIL, FSTINI, FSTANL
           FROM ACFCS AS A
           JOIN LAST_STS AS B
           ON  A.FCSKEY = B.FSTFCS
           AND A.FCSINT = B.FSTINT AND B.RN = 1
           WHERE (:P_FCSKEY = '999999' OR :P_FCSKEY = A.FCSKEY)
           AND (:P_FCSINT = '' OR :P_FCSINT = A.FCSINT)
           AND (:P_FCSSTS = '' OR :P_FCSSTS = A.FCSSTS)
           AND (:P_FSTANL = '' OR :P_FSTANL = B.FSTANL)
           AND (:P_FSTINI = :default_st OR :P_FSTINI <= A.FCSCRD)
           AND (:P_FSTEND = :default_st OR :P_FSTEND >= A.FCSCRD)
           ORDER BY FCSSTS DESC;

           EXEC SQL OPEN LIST_CASES;
           EXEC SQL FETCH LIST_CASES INTO :data;

           dow sqlcod = 0;
             res_general_pt = $_general_data_predict(data.FCSKEY:data.FCSINT);
             eval-corr data_rec = data;
             eval-corr data_rec = res_general_pt;
             data_rec.fcsint_masked = $_masking_token(data_rec.fcsint);
             cb_proc(%addr(data_rec));
             clear data_rec;
             EXEC SQL FETCH LIST_CASES INTO :data;
           enddo;
         endif;
         EXEC SQL CLOSE LIST_CASES;
         return res;
       end-proc;
       //-----------------------------------------------------------------*
       // Get record
        // Description procedure: get case record
        // Parameters:
        // @p_fcskey: case number
        // @p_fcsint: card number
       //-----------------------------------------------------------------*
       dcl-proc $ai0405_get_case_record export;
         dcl-ds res likeds(ds_ai0405_case_data_assign);
         dcl-ds data ext inz(*extdft) extname('ACFCS') qualified;
           FSTINI timestamp;
           FSTSTS char(1);
           FSTANL char(10);
         end-ds;
         dcl-pi *n likeds(res);
           p_fcskey packed(6);
           p_fcsint char(21);
         end-pi;
         res.auth = $ai0405_auth_handler(1);
         res.feedback = '200';
         %int('200');
         if res.auth.allowed;
           EXEC SQL SELECT FCSKEY, FCSINT, FCSSTS, FCSCRD, FCSFIL,
           FSTINI, FSTSTS, FSTANL
           INTO :data
           FROM ACFCS AS A INNER JOIN ACFST AS B
           ON  A.FCSKEY = B.FSTFCS
           AND A.FCSINT = B.FSTINT
           AND A.FCSSTS = B.FSTSTS
           WHERE A.FCSINT = :p_fcsint
           AND A.FCSKEY = :p_fcskey
           AND B.FSTINI = (SELECT MAX(FSTINI) FROM
           ACFST WHERE FSTFCS = A.FCSKEY AND FSTINT = A.FCSINT);
           if sqlcod = 0;
             eval-corr res = data;
             res.full_name = $_get_users_fullname(data.FSTANL);
             res.fcsint_masked = $_masking_token(data.fcsint);
           else;
             res.feedback = '404';
           endif;
         endif;
         return res;
       end-proc;
       //-----------------------------------------------------------------*
       // list transactions
        // Description procedure: list card transactions with filters
        // Parameters:
        // @card: card number or token
        // @amount: transaction amount
        // @last_step: last step
        // @str_date: start date
        // @str_time: start time
        // @end_date: end date
        // @end_time: end time
        // @number_records: number of records to return
        // @pointer_proc: pointer to callback procedure for each record
       //-----------------------------------------------------------------*
       dcl-proc $ai0405_list_card_transactions export;
         dcl-ds data ext inz(*extdft) extname('ACFTP') qualified end-ds;
         dcl-s pan_or_token char(21);
         dcl-s count_cases_open_card packed(3) inz(0);
         dcl-c nt   const(1000000);//Numeric constant for time
         dcl-ds res likeds(ds_ai0405_read_transactions);
         dcl-s aux_str_date zoned(14);
         dcl-s aux_end_date zoned(14);
         dcl-s res_check_transaction char(3);

         dcl-pi *n likeds(res);
           card      char(21) const;
           amount    zoned(19:2) const;
           last_step char(2)  const;
           str_date  zoned(8) const;
           str_time  zoned(6) const;
           end_date  zoned(8) const;
           end_time  zoned(6) const;
           number_records zoned(10);
           pointer_proc pointer(*proc) const;
         end-pi;

         dcl-pr cb_proc extproc(pointer_proc);
           *n pointer  const;
           *n char(3)  const;
           *n char(40) const;
           *n pointer  const;
         end-pr;

         clear pan_or_token;
         res.err_cod = '200';
         res.auth = $ai0405_auth_handler(6);
         if res.auth.allowed;

           if card = *blanks;
             res.err_cod = '500';
             return res;
           endif;

           pan_or_token = $_pan_convert_or_token(card);
           aux_end_date = end_date * nt + end_time;
           aux_str_date = str_date * nt + str_time;

           EXEC SQL DECLARE LIST_PREDICTIONS CURSOR FOR
           SELECT * FROM ACFTP
           WHERE (FTPOFL *:nt + FTPOHL) BETWEEN
           :aux_str_date AND :aux_end_date
           AND FTPINT = :pan_or_token
           AND (FTPIVT = :amount OR :amount = '0')
           AND FTPFCS = '-2'
           ORDER BY FTPOFL, FTPOHL DESC
           LIMIT :number_records;
           EXEC SQL OPEN LIST_PREDICTIONS;
           EXEC SQL FETCH LIST_PREDICTIONS INTO :data;

           dow sqlcod = 0;
             res_check_transaction = $_get_transaction_fields(data);
             if last_step <> *blanks and last_step <> LHTIUP;
               EXEC SQL FETCH LIST_PREDICTIONS INTO :data;
               iter;
             endif;
             cb_proc(%addr(data)
                    :res_check_transaction
                    :PAIDSM
                    :%addr(rc_ai0405_azlht));
             clear res_check_transaction;
             clear rc_ai0405_appai;
             clear rc_ai0405_azlht;
             EXEC SQL FETCH LIST_PREDICTIONS INTO :data;
           enddo;
           EXEC SQL CLOSE LIST_PREDICTIONS;

           EXEC SQL SELECT COUNT(*) INTO :count_cases_open_card
           FROM ACFCS WHERE FCSINT = :card AND FCSSTS = '1';
           res.an_open_case = (sqlcod = 0 and count_cases_open_card > 0);
         endif;
         return res;
       end-proc;
       //-----------------------------------------------------------------*
       // get transaction
        // Description procedure: get transaction details
        // Parameters:
        // @p_data: transaction key data
       //-----------------------------------------------------------------*
       dcl-proc $ai0405_get_transaction export;
         dcl-ds res likeds(ds_ai0405_res_transaction);
         dcl-pi *n likeds(res);
           p_data likeds(ds_ai0405_acftp);
         end-pi;
         res.err_cod = '200';
         res.aux_err_cod = 0;
         res.auth = $ai0405_auth_handler(7);
         if res.auth.allowed;
           chain(n) (p_data.FTPKEY:-2:p_data.FTPINT) ACFTPL0;
           if %found(ACFTPL0);
             eval-corr res.data_ftp = rc_ai0405_acftp;
             chain(n) (FTPOAI:FTPONT:FTPOCJ:FTPINT
                      :FTPOSQ:FTPOFL:FTPOHL:FTPIVT) AZLHT;
             if %found(AZLHT);
               eval-corr res.data = rc_ai0405_azlht;
               res.data_details = $_get_descriptions(rc_ai0405_azlht);
             else;
               res.err_cod = '404';
               res.aux_err_cod = 2;
             endif;
           else;
             res.err_cod = '404';
             res.aux_err_cod = 1;
           endif;
         endif;
         return res;
       end-proc;
       //-----------------------------------------------------------------*
       // assign cases
        // Description procedure: assign case to analyst
        // Parameters:
        // @p_fcskey: case number
        // @p_fcsint: card number
        // @p_fcssts: current case status
        // @p_set_anl: analyst to assign
        // @p_set_usr: user who is assigning
        // @p_set_sts: new case status
       //-----------------------------------------------------------------*
       dcl-proc $ai0405_assign_cases export;
         dcl-ds res_func likeds(ds_ai0405_res_functions);
         dcl-s curr_timestamp timestamp inz(*sys);
         dcl-s res_user_analyst_assignable zoned(1);
         dcl-s curr_sts char(1);
         dcl-s curr_anl char(10);
         dcl-s count_undefined packed(6);
         dcl-pi *n likeds(res_func);
           p_fcskey  packed(6) const;
           p_fcsint  char(21) const;
           p_fcssts  char(1) const;
           p_set_anl char(10) const;
           p_set_usr char(10) const;
           p_set_sts char(1) const;
         end-pi;

         res_func.feedback = '200';
         res_func.auth = $ai0405_auth_handler(%int(p_set_sts));
         if res_func.auth.allowed;
           //check user analyst permission asignable
           res_user_analyst_assignable = $_check_assignable_user(p_set_anl);
           //check fields for assignment
           res_func.cod_err = '00';
           if p_set_anl = *blanks;
             res_func.cod_err = '01';
           elseif p_set_sts = *blanks or p_set_sts = '1';
             res_func.cod_err = '02';
           elseif res_user_analyst_assignable <> 0
           and p_set_sts <> '4';
             //0: ok!!
             //1: user not found
             //2: profile not found or not analyst
             //3: not found permission for analyst user
             if res_user_analyst_assignable = 1;
               res_func.cod_err = '05';
       //      elseif res_user_analyst_assignable = 2;
       //        res_func.cod_err = '06';
             elseif res_user_analyst_assignable = 3;
               res_func.cod_err = '07';
             endif;
           else;
             EXEC SQL SELECT FSTSTS, FSTANL INTO :curr_sts, :curr_anl
             FROM ACFST AS A WHERE A.FSTFCS = :p_fcskey AND A.FSTINT = :p_fcsint
             AND A.FSTSTS = :p_fcssts
             AND A.FSTINI = (SELECT MAX(FSTINI) FROM ACFST WHERE
             A.FSTFCS = FSTFCS AND A.FSTINT = FSTINT AND A.FSTSTS = FSTSTS);
             if p_set_anl = curr_anl and p_set_sts = curr_sts;
               res_func.cod_err = '03';
             endif;
           endif;
           if p_set_sts = CLOSURE_STATUS;
             count_undefined = 0;
             EXEC SQL SELECT COUNT(1) INTO :count_undefined FROM ACFTP
             WHERE FTPFCS = :p_fcskey AND FTPINT = :p_fcsint
             AND FTPFRD = '';
             if count_undefined > 0;
               res_func.cod_err = '04';
             endif;
           endif;
           if res_func.cod_err = '00';//check is ok
             chain (p_fcskey:p_fcsint) ACFCSL0;
             if %found(ACFCSL0);
               FCSSTS = p_set_sts;
               update(e) RACFCS0;
               if %error;
                 res_func.feedback = '500';
                 return res_func;
               endif;
               //update current state
               setgt  (p_fcskey:p_fcsint:p_fcssts) ACFSTL2;
               readpe (p_fcskey:p_fcsint:p_fcssts) ACFSTL2;
               FSTEND = curr_timestamp;
               update(e) RACFST;
               if %error;
                 //rollback
                 chain (p_fcskey:p_fcsint) ACFCSL0;
                 FCSSTS = p_FCSSTS;
                 update(e) RACFCS0;
                 res_func.feedback = '500';
               else;
                 //create new state
                 FSTINI = curr_timestamp;
                 FSTSTS = p_set_sts;
                 FSTANL = p_set_anl;
                 FSTUSR = p_set_usr;
                 if CLOSURE_STATUS = p_set_sts;
                   FSTEND = curr_timestamp;
                 else;
                   FSTEND = *loval;
                 endif;
                 write(e) RACFST;
               endif;
             else;
               res_func.feedback='404';
             endif;
           else;
             res_func.feedback='400';
           endif;
         endif;
         return res_func;
       end-proc;
       //-----------------------------------------------------------------*
       // add transaction (case, status, prediction)
        // Description procedure: add transaction and link to case
        // Parameters:
        // @p_data: transaction data
       //-----------------------------------------------------------------*
       dcl-proc $ai0405_add_transaction export;
         dcl-ds res likeds(ds_ai0405_res_add_transactions);
         dcl-s curr_datetime timestamp inz(*sys);
         dcl-s curr_datetime_loval timestamp inz(*loval);
         dcl-s curr_max_case packed(6) inz(0);
         dcl-s card_number char(21);
         dcl-pi *n likeds(res);
           data_trans likeds(ds_ai0405_acftp) const;
         end-pi;
         res.auth = $ai0405_auth_handler(8);
         if res.auth.allowed;
           res.err_cod = '00';
           res.feedback = '200';
           card_number = data_trans.FTPINT;
           res.card_number = card_number;
           chain (data_trans.FTPKEY:-2:data_trans.FTPINT) ACFTPL0;
           if %found(ACFTPL0);
             chain(n) (data_trans.FTPINT:'1') ACFCSL1;
             if %found(ACFCSL1);
               FTPFCS = FCSKEY;
               res.curr_id_code = FCSKEY;
               update(e) racftp0;
             else;
               EXEC SQL SELECT MAX(FCSKEY) INTO :curr_max_case FROM ACFCS
               WHERE FCSINT = :card_number;
               if sqlcod = 0;
                 curr_max_case += 1;
               endif;
               res.curr_id_code = curr_max_case;
               FCSKEY = curr_max_case;
               FCSINT = data_trans.FTPINT;
               FCSSTS = '1';
               FCSCRD = curr_datetime;
               FCSFIL = *blanks;
               write(e) racfcs1;
               FSTINI = curr_datetime;
               FSTFCS = curr_max_case;
               FSTINT = data_trans.FTPINT;
               FSTUSR = '';
               FSTANL = '';
               FSTSTS = '1';
               FSTEND = curr_datetime_loval;
               FSTFIL = *blanks;
               write(e) RACFST;
               FTPFCS = curr_max_case;
               update(e) racftp0;
             endif;
           else;
             res.feedback = '404';
           endif;
         endif;
         return res;
       end-proc;
       //-----------------------------------------------------------------*
       // GET USERS (ANALYST)
        // Description procedure: get list of users with analyst profile
        // Parameters:
        // @pointer_proc: pointer to callback procedure for each record
       //-----------------------------------------------------------------*
       dcl-proc $ai0405_get_analyst export;
         dcl-ds res likeds(ds_ai0405_res_analyst);
         dcl-ds data ext inz(*extdft) extname('AUPFN') qualified end-ds;
         dcl-ds data_passed likeds(ds_ai0405_data_analysts);
         dcl-pi *n likeds(res);
           pointer_proc pointer(*proc) const;
         end-pi;
         dcl-pr cb_proc extproc(pointer_proc);
           *n pointer const;
         end-pr;
         res.feedback = '200';
         res.auth = $ai0405_auth_handler(9);
         if res.auth.allowed;
           EXEC SQL DECLARE GET_ANLS CURSOR FOR
           SELECT * FROM AUPFN
           WHERE PFNTIP = 'U' AND PFNFUN = 'AM0409ALT';
           EXEC SQL OPEN GET_ANLS;
           EXEC SQL FETCH GET_ANLS INTO :DATA;
           DOW SQLCOD = 0;
             data_passed.username = data.PFNPER;
             data_passed.fullname = $_get_users_fullname(data.PFNPER);
             cb_proc(%addr(data_passed));
             EXEC SQL FETCH GET_ANLS INTO :DATA;
           ENDDO;
           EXEC SQL CLOSE GET_ANLS;
         endif;
         return res;
       end-proc;
       //-----------------------------------------------------------------*
       // GET USERS (ASSIGNED ANALYSTS)
        // Description procedure: get list of users with assigned cases
        // Parameters:
        // @pointer_proc: pointer to callback procedure for each record
       //-----------------------------------------------------------------*
       dcl-proc $ai0405_get_assigned_analysts export;
         dcl-ds res likeds(ds_ai0405_res_analyst);
         dcl-ds data_passed likeds(ds_ai0405_data_analysts);
         dcl-s username char(10);
         dcl-pi *n likeds(res);
           pointer_proc pointer(*proc) const;
         end-pi;

         dcl-pr cb_proc extproc(pointer_proc);
           *n pointer const;
         end-pr;

         res.feedback = '200';
         res.auth = $ai0405_auth_handler(9);
         if res.auth.allowed;
           EXEC SQL DECLARE GET_ASSIGNED_ANLS CURSOR FOR
           SELECT DISTINCT FSTANL FROM ACFST WHERE FSTANL <> '';
           EXEC SQL OPEN GET_ASSIGNED_ANLS;
           EXEC SQL FETCH GET_ASSIGNED_ANLS INTO :username;
           DOW SQLCOD = 0;
             data_passed.username = username;
             data_passed.fullname = $_get_users_fullname(username);
             cb_proc(%addr(data_passed));
             EXEC SQL FETCH GET_ASSIGNED_ANLS INTO :username;
           ENDDO;
           EXEC SQL CLOSE GET_ASSIGNED_ANLS;
         endif;
         return res;
       end-proc;
       //-----------------------------------------------------------------*
       // Private procedure---------------------------------------------- *
       //-----------------------------------------------------------------*
       //-----------------------------------------------------------------*
       // get prediction data
       //-----------------------------------------------------------------*
       // @case_number case key
       // @pan_number card number
       // @return:
       //        - {ftptrx_num} total trx number
       //        - {ftppro_avg} average prediction
       //-----------------------------------------------------------------*
       dcl-proc $_general_data_predict;
         dcl-ds res likeds(ds_ai0405_general_data_pt);
         dcl-s total_transactions packed(20);
         dcl-s sum_percentage packed(20:3);
         dcl-pi *n  likeds(res);
           case_number packed(6);
           pan_number  char(21);
         end-pi;
         res.ftppro_avg = 0;
         res.ftptrx_num = 0;

         EXEC SQL SELECT COUNT(*), SUM(FTPPRO)
         INTO :total_transactions, :sum_percentage FROM ACFTP
         WHERE FTPFCS = :case_number AND FTPINT = :pan_number;

         res.ftptrx_num = total_transactions;
         monitor;
           res.ftppro_avg  = sum_percentage / total_transactions;
         on-error;
           res.ftppro_avg = 0;
         endmon;
         return res;
       end-proc;
       //-----------------------------------------------------------------*
       // Check assignable user permissions
        // return:
        // 0: ok!!
        // 1: user not found
        // 2: profile not found or not analyst (deleted)
        // 3: not found permission for analyst user
        // Parameters:
        // @analyst: user to check
       //-----------------------------------------------------------------*
       dcl-proc $_check_assignable_user;
         dcl-s vusrper char(10);
         dcl-c cod_assignable const('AM0409ALT');
         dcl-pi *n zoned(1);
           analyst char(10) const;
         end-pi;

         chain(n) analyst AUUSR;
         if %found(AUUSR);
           vusrper = usrper;
         else;
           return 1;
         endif;

         chain(n) ('AUTHORIZER':cod_assignable:'U':analyst) AUPFNL1;
         if not %found(AUPFNL1);
           return 3;
         endif;
         return 0;
       end-proc;
       //-----------------------------------------------------------------*
       // Get user's full name
        // Parameters:
        // @user_name: user to get full name
        // @return: full name or 'NA' if not found
       //-----------------------------------------------------------------*
       dcl-proc $_get_users_fullname;
         dcl-s fullname char(30);
         dcl-pi *n char(30);
           user_name char(10) const;
         end-pi;
         EXEC SQL SELECT USRNOM INTO :fullname FROM AUUSR
         WHERE USRUSU = :user_name;
         if sqlcod = 0;
           return fullname;
         endif;
         return 'NA';
       end-proc;
       //-----------------------------------------------------------------*
       // masking token
        // Parameters:
        // @token: token to mask
        // @return: masked token
       //-----------------------------------------------------------------*
       dcl-proc $_masking_token;
         dcl-s token_masked char(21);
         dcl-s verr char(2);
         dcl-pi *n char(21);
           p_token char(21);
         end-pi;
         AZ1804(p_token:token_masked:verr);
         return token_masked;
       end-proc;
       //-----------------------------------------------------------------*
       // check pan convert or token
        // Parameters:
        // @token_pan: pan or token
        // @return: if pan (16 digits) convert to token else return token
       //-----------------------------------------------------------------*
       dcl-proc $_pan_convert_or_token;
         dcl-s verr char(2);
         dcl-s vpan char(21);
         dcl-s res_token char(21);
         dcl-pi *n char(21);
           token_pan char(21) const;
         end-pi;
         clear res_token;
         vpan = token_pan;
         if %len(%trim(token_pan)) = 16;
           AZ1802(vpan:res_token:verr);
           return res_token;
         endif;
         return token_pan;
       end-proc;
       //----------------------------------------------------------------------*
       // transaction description details
       // Parameters:
        // @p_azlht: AZLHT record
        // @return: ds_ai0405_desc_azlht with descriptions
       //----------------------------------------------------------------------*
       dcl-proc $_get_descriptions;
         dcl-ds res likeds(ds_ai0405_desc_azlht);
         dcl-pi *n likeds(res);
           p_azlht likeds(ds_ai0405_azlht);
         end-pi;
         in AZCFG;
         //Applicative desc
         chain(n) (v_site:p_azlht.lhtapl) AZPRM;
         if %found(AZPRM);
           res.dsc_lhtapl = PRMTIT;
         endif;
         chain(n) (v_site:p_azlht.lhtord) AZPRM;
         if %found(AZPRM);
           res.dsc_lhtord = PRMTIT;
         endif;
         chain(n) (v_site:p_azlht.lhterd) AZPRM;
         if %found(AZPRM);
           res.dsc_lhterd = PRMTIT;
         endif;
         chain(n) (p_azlht.lhtapl:p_azlht.lhtirs) AZLER;
         if %found(AZLER);
           res.dsc_lhtirs = LERDSC;
         endif;
         chain(n) p_azlht.lhtimo APPAIL1;
         if %found(APPAIL1);
           res.dsc_lhtivt = PAIDSM;
         endif;
         return res;
       end-proc;
       //-----------------------------------------------------------------*
       // check transactions details azlht
       //-----------------------------------------------------------------*
       dcl-proc $_get_transaction_fields;
        dcl-pi *n char(3);
          key_lht likeds(ds_ai0405_acftp) const;
        end-pi;
        chain(n) (key_lht.FTPOAI:key_lht.FTPONT:key_lht.FTPOCJ
                 :key_lht.FTPINT:key_lht.FTPOSQ:key_lht.FTPOFL
                 :key_lht.FTPOHL:key_lht.FTPIVT) AZLHT;
        if %found(AZLHT);
          chain(n) LHTIMO APPAIL1;
          return '200';
        endif;
        return '404';
       end-proc; 