import dotenv from 'dotenv';

dotenv.config();

const crypto = require('crypto');

const usersStorage = new Map();

const generateUserToken = () => crypto.randomBytes(32).toString('base64');
exports.requireAuthHeader = (req, res, next) => {
  // 'Check if request is authorized with token from POST /authorize'
  if ((!req.headers.authorization || !req.headers.authorization.startsWith('Bearer '))) {
    res.statusMessage = "No Authorization header";
    res.status(401).send('Unauthorized');
    return;
  }

  const userToken = req.headers.authorization.split('Bearer ')[1];

  if (!usersStorage.has(userToken)) res.status(401).send('Unauthorized');

  req.user = { sender: usersStorage.get(userToken) };
  next();
};

exports.authenticate = async (req, res) => {
  if (!req.body || !req.body.sender) {
    res.statusMessage = 'You should specify sender in body';
    res.status(400).end();
    return;
  }
  const token = generateUserToken();

  usersStorage.set(token, req.body.sender);

  res.json({ authToken: token });
};

exports.users = async (req, res) => {
  res.json({ users: Array.from(new Set(usersStorage.values())) });
};
