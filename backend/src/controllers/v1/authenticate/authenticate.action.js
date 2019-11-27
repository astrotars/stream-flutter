import dotenv from 'dotenv';

dotenv.config();

const crypto = require('crypto');

const usersStorage = new Map();

const generateUserToken = () => crypto.randomBytes(32).toString('base64');
const pseudoEncodeToken = (sender, token) => usersStorage.set(token, sender);
const pseudoDecodeToken = (token) => usersStorage.get(token);
const pseudoVerifyToken = (token) => usersStorage.has(token);

exports.requireAuthHeader = (req, res, next) => {
  // 'Check if request is authorized with token from POST /authorize'
  if ((!req.headers.authorization || !req.headers.authorization.startsWith('Bearer '))) {
    res.statusMessage = "No Authorization header";
    res.status(401).send('Unauthorized');
    return;
  }

  const userToken = req.headers.authorization.split('Bearer ')[1];

  if (!pseudoVerifyToken(userToken)) res.status(401).send('Unauthorized');

  req.user = { sender: pseudoDecodeToken(userToken) };
  next();
};

exports.authenticate = async (req, res) => {
  if (!req.body || !req.body.sender) {
    res.statusMessage = 'You should specify sender in body';
    res.status(400).end();
    return;
  }
  const token = generateUserToken();

  pseudoEncodeToken(req.body.sender, token);

  res.json({ authToken: token });
};
