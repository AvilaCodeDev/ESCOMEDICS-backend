const { response } = require("express");
const { select, callTableFunction, callStoreProcedure } = require("../db/connection");
const { generarJWT } = require("../helpers/jwt");

const loginUsuario = async( req, res = response ) => {
    try {
        const { email, password } = req.body;
        const result = await callTableFunction('fn_001_login', [email,password]);
        const { id_usuario:uid, nombre, ap_paterno, ap_materno, id_rol, email_usuario } = result.recordset[0];

        if( uid == 0 ){
            return res.json({
                ok: false,
                msg: "Correo y/o contraseña incorrectos"
            })
        }

        const userToken = await generarJWT (uid, email);

        return res.json({
            ok: true,
            uid,
            nombre,
            ap_paterno,
            ap_materno,
            id_rol,
            userToken,
            email_usuario
        })

    } catch (error) {
        console.log( error );
        return res.status(500).json({
            ok: false,
            msg: "Favor de comunicarse con el administrador"
        })
    }
}

const obtieneDatosUsuario = async ( req, res = response ) => {
    try {

        const {uid, id_rol} = req.body;

        const result = await callStoreProcedure("sp_010_obtiene_datos_usuario", [uid,id_rol]);
        const data = result.recordset[0];
        const result_menu = await callTableFunction("fn_002_obtiene_menu_usuario", [id_rol]);
        let {json_menu } = result_menu.recordset[0];
        json_menu = JSON.parse(json_menu);
        const { opcion_menu } = json_menu; 

        return res.json({
            ok: true,
            ...data,
            opcion_menu
        })
    } catch (error) {
        console.log( error );
        return res.status(500).json({
            ok: false,
            msg: "Favor de comunicarse con el administrador"
        })
    }
}

const revalidarToken = async (req, res = response ) => {

    const { uid, name } = req;
    // Generar JWT
    const token = await generarJWT( uid, name );

    res.json({
        ok: true,
        uid, name,
        token
    })
}

module.exports = {
    loginUsuario,
    revalidarToken,
    obtieneDatosUsuario
}