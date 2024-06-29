const sql = require("mssql");
const sqlConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_HOST,
    database: process.env.DB_NAME,
    dateStrings: true,
    options: {
        trustedConnection: true,
        trustServerCertificate: true
    }
};

const connection = async() => {
    try {
        return await sql.connect( sqlConfig );
    } catch (error) {
        console.log( error );
    }
}

const callTableFunction = async( nombreFunction, params ) => {
    try {
        const consulta = `select * from dbo.${nombreFunction}('${params.join("','")}')`;
        const sql = await connection();
        const result = await sql.query( consulta );   
        return result;
    } catch (error) {
        console.log( error );
    }
}

const callStoreProcedure = async ( nombreProcedure, params) => {
    try {
        const consulta = `exec dbo.${ nombreProcedure } '${ params.join("','")}'`;
        const sql = await connection();
        const result = await sql.query( consulta );
        return result;
    } catch (error) {
        console.log( error );
    }
}

const select = async( campos, tabla, condicion) => {
    try {
        const sql = await connection();
        const result = await sql.query(`select ${ campos } from ${ tabla } ${ condicion ? ` where ${ condicion }`:'' }`);
        return result;
    } catch (error) {
        console.log( error );
    }
}

const insert = async( tabla ,campos, values ) => {
    try {
        const sql = await connection();
        const resutl = await sql.query(`insert into ${ tabla } (${ campos }) values ( ${values} )`);
        return resutl;
    } catch (error) {
        console.log( error )
    }
}

const update = async( tabla, camposValue, condicion ) => {
    try {
        const sql = await connection();
        const result = await sql.query(`update ${ tabla } set ${ camposValue } where ${ condicion }`);
        return result;   
    } catch (error) {
        console.log( error );
    }
}

const borrar = async( tabla, condicion ) => {
    try {
        const sql = await connection();
        const result = await sql.query(`delete from ${ tabla } where ${ condicion } `);
        return result;
    } catch (error) {
        console.log( error );
    }
}

module.exports = {
    select,
    insert,
    update,
    borrar,
    callTableFunction,
    callStoreProcedure
}