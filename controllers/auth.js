const { response } = require("express");
const { select } = require("../db/connection");
const { generarJWT } = require("../helpers/jwt");

const loginUsuario = async( req, res = response ) => {
    try {
        const { email, password } = req.body;
        const usuario = await select("*","usuarios",`correo_usuario='${email}'`);
        if( usuario?.rowsAffected == 0 ){
            return res.status(400).json({
                ok: false,
                msg: "El usuario no existe con ese email",
                error: "email"
            })
        }
        
        if( usuario.recordset[0].password_usuario != password ){
            return res.status(400).json({
                ok: false,
                msg: "Contraseña Inconrrecta",
                error: "password"
            });
        }

        

        const userToken = await generarJWT( usuario.recordset[0].id_usuario, usuario.recordset[0].correo_usuario );

        return res.status(200).json({
            ok: true,
            uid: usuario.recordset[0].id_usuario,
            userToken
        });

    } catch (error) {
        console.log( error );
        return response.status(500).json({
            ok: false,
            msg: "Favor de comunicarse con el administrador"
        })
    }
}

const revalidarToken = async (req, res = response ) => {

    const { uid, name } = req;

    console.log( req );

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
    revalidarToken
}