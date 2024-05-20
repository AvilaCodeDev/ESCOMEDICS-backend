const { Router } = require('express');
const { check } = require('express-validator');
const { loginUsuario, revalidarToken } = require('../controllers/auth');
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

router.get(
    '/renew',
    validarJWT,
    revalidarToken
);

module.exports = router;