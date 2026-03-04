export const figurative_constants = [
  "*BLANKS",
  "*BLANK",
  "*ZEROS",
  "*ZERO",
  "*HIVAL",
  "*LOVAL",
  "*NULL",
  "*ON",
  "*OFF",
  "*ALL",
] as const;

export const file_operations = [
  "*INPUT",
  "*OUTPUT",
  "*UPDATE",
  "*DELETE",
  "*KEY",
  "*START",
  "*END",
  "*NEXT",
  "*PREV",
  "*FIRST",
  "*LAST",
  "*CANCL",
  "*DETL",
  "*GET",
] as const;
const control_options = [
  "*YES",
  "*NO",
  "*CALLER",
  "*NEW",
  "*INHERIT",
  "*SRCSTMT",
  "*NODEBUGIO",
  "*NOSRCSTMT",
  "*STDSQL",
  "*SYS",
  "*JOB",
  "*DATE",
  "*TIME",
  "*ISO",
  "*USA",
  "*EUR",
  "*JIS",
  "*MDY",
  "*DMY",
  "*YMD",
] as const;
const parameter_passing = [
  "*NOPASS",
  "*OMIT",
  "*VARSIZE",
  "*STRING",
  "*RIGHTADJ",
  "*CONVERT",
] as const;
const indicators = [
  "*INLR",
  "*INU1",
  "*INU2",
  "*INU3",
  "*INU4",
  "*INU5",
  "*INU6",
  "*INU7",
  "*INU8",
  "*IN01",
  "*IN02", // ... hasta *IN99
  "*INKA",
  "*INKB",
  "*INKC",
  "*INKD",
  "*INKE",
  "*INKF",
  "*INKG",
  "*INKH", // Funciones F1-F24
  "*INKL",
  "*INKM",
  "*INKN",
  "*INKP",
  "*INKQ",
  "*INKR",
  "*INKS",
  "*INKT",
  "*INKU",
  "*INKV",
  "*INKW",
  "*INKX",
] as const;
const data_definition = [
  "*EXT",
  "*VAR",
  "*CTDATA",
  "*PSSR",
  "*ENTRY",
  "*LIKE",
  "*ALIGN",
  "*NEXT",
  "*QUALIFIED",
] as const;
const builtInFunctionsPrefix = "%";
const special_values = [
  "*DATE",
  "*DAY",
  "*MONTH",
  "*YEAR",
  "*SYS",
  "*LIBL",
  "*CURLIB",
] as const;

export const rpgle_declare_block_endings = {
  declarations: [
    { start: 'dcl-ds',   end: 'end-ds' },
    { start: 'dcl-pr',   end: 'end-pr' },
    { start: 'dcl-pi',   end: 'end-pi' },
    { start: 'dcl-proc', end: 'end-proc' },
    { start: 'dcl-enum', end: 'end-enum' }
  ],
  logicControl: [
    { start: 'if',       end: 'endif' },
    { start: 'select',   end: 'endsl' },
    { start: 'monitor',  end: 'endmon' },
    { start: 'begsr',    end: 'endsr' }
  ],
  loops: [
    { start: 'dow',      end: 'enddo' },
    { start: 'dou',      end: 'enddo' },
    { start: 'for',      end: 'endfor' }
  ]
};

export const rpgle_declarations = [
/*   { tag: 'dcl-ds', description: 'Data Structures (Estructuras de datos)' },
  { tag: 'dcl-pr', description: 'Prototype (Prototipo para llamadas externas)' },
  { tag: 'dcl-pi', description: 'Procedure Interface (Parámetros recibidos)' },
  { tag: 'dcl-proc', description: 'Procedure (Inicio de procedimiento)' },
  { tag: 'dcl-enum', description: 'Enumeration (Lista de valores constantes)' }, */
  { tag: 'dcl-f',  description: 'Files (Archivos)' },
  { tag: 'dcl-s',  description: 'Standalone Variables (Variables sueltas)' },
  { tag: 'dcl-c',  description: 'Constants (Constantes)' },
] as const;

export const rpgleDataTypes = [
  { tag: 'PACKED',  rpgle: 'packed(len:dec)',  desc: 'Decimal empacado (Base de datos)' },
  { tag: 'ZONED',   rpgle: 'zoned(len:dec)',   desc: 'Decimal zonado (Formato legible)' },
  { tag: 'INT',     rpgle: 'int(3|5|10|20)',   desc: 'Entero con signo (Eficiente)' },
  { tag: 'UNS',     rpgle: 'uns(3|5|10|20)',   desc: 'Entero sin signo' },
  { tag: 'CHAR',    rpgle: 'char(len)',        desc: 'Cadena de longitud fija' },
  { tag: 'VARCHAR', rpgle: 'varchar(len)',     desc: 'Cadena de longitud variable' },
  { tag: 'IND',     rpgle: 'ind',              desc: 'Indicador booleano' },
  { tag: 'DATE',    rpgle: 'date',             desc: 'Fecha (ISO, DMY, etc.)' },
  { tag: 'TIMESTAMP', rpgle: 'timestamp',      desc: 'Fecha y hora con microsegundos' },
  { tag: 'POINTER', rpgle: 'pointer',          desc: 'Dirección de memoria' }
] as const;

export const rpgle_definitions_keywords = {
  structural: ['DIM', 'QUALIFIED', 'TEMPLATE', 'LIKEDS', 'LIKEREC', 'EXTNAME', 'PREFIX', 'ALIGN', 'BASED', 'POS'],
  initialization: ['INZ', 'CONST', 'EXPORT', 'IMPORT', 'STATIC'],
  parameters: ['VALUE', 'OPTIONS', 'EXTPGM', 'EXTPROC', 'RTNPARM'],
  fileSpecific: ['KEYED', 'USAGE', 'EXTFILE', 'EXTMBR', 'RENAME', 'COMMIT', 'INFSR', 'INDDS', 'HANDLER'],
  dataTypesAttributes: ['LEN', 'VARYING', 'CCSID', 'PACKEVEN']
};