import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const User = sequelize.define(
  'User',
  {
    uid: {
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4,
    },
    name: { type: DataTypes.TEXT },
    email: { type: DataTypes.TEXT },
    image: { type: DataTypes.TEXT },
    youtube: { type: DataTypes.TEXT },
    facebook: { type: DataTypes.TEXT },
    twitter: { type: DataTypes.TEXT },
    instagram: { type: DataTypes.TEXT },
    followers_count: { type: DataTypes.INTEGER, defaultValue: 0 },
    following: { type: DataTypes.ARRAY(DataTypes.UUID), defaultValue: [] },
    created_at: { type: DataTypes.DATE },
    updated_at: { type: DataTypes.DATE },
  },
  {
    tableName: 'users',
    schema: 'public',
    timestamps: false, // table already has its own created_at / updated_at columns
  }
);

export default User;
