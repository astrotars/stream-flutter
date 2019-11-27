import dotenv from 'dotenv';

const { JwtGenerator } = require('virgil-sdk');
const { VirgilCrypto, VirgilAccessTokenSigner } = require('virgil-crypto');

dotenv.config();

const virgilCrypto = new VirgilCrypto();

const generator = new JwtGenerator({
  appId: process.env.VIRGIL_APP_ID,
  apiKeyId: process.env.VIRGIL_KEY_ID,
  apiKey: virgilCrypto.importPrivateKey(process.env.VIRGIL_PRIVATE_KEY),
  accessTokenSigner: new VirgilAccessTokenSigner(virgilCrypto)
});


exports.virgilCredentials = async (req, res) => {
  const virgilJwtToken = generator.generateToken(req.user.sender);

  res.json({ token: virgilJwtToken.toString() });
};
