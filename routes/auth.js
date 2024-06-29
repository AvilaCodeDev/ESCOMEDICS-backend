const { Router } = require('express');
const { check } = require('express-validator');
const { loginUsuario, revalidarToken, obtieneDatosUsuario } = require('../controllers/auth');
const { validarCampos } = require('../middlewares/validar-campos');
const { validarJWT } = require('../middlewares/validar-jwt');

const router = Router();

router.post(
    '/',
    [
        check('email', 'El email es obligatorio').isEmail(),
        check('password', 'El password debe contener minimo 6 caracteres').isLength({ min: 3 }),
        validarCampos
    ],
    loginUsuario
);

router.post(
    '/obtieneDatosUsuario',
    [
        check('uid', "El id del usuario es obligatorio").isInt(),
        check("id_rol", "El rol del usuario es obligatorio").isInt()
    ],
    obtieneDatosUsuario
)

router.get(
    '/renew',
    validarJWT,
    revalidarToken
);

module.exports = router;