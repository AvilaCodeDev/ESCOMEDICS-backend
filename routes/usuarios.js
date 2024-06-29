const { Router } = require('express');
const { check } = require('express-validator');
const { validarCampos } = require('../middlewares/validar-campos');
const { validarJWT } = require('../middlewares/validar-jwt');
const { consultaUsuarios, registraUsuario, getDetallesUsuario } = require('../controllers/usuarios');

const router = Router();

router.post(
    '/registraUsuario',
    validarJWT,
    registraUsuario
);

router.get(
    '/',
    validarJWT,
    consultaUsuarios
);

router.get(
    '/getDetallesUsuario',
    getDetallesUsuario
)

module.exports = router;