import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const MemberEarning = sequelize.define(
  'MemberEarning',
  {
    id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      autoIncrement: true,
    },
    video_id: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    likes_earning: {
      type: DataTypes.DECIMAL,
      allowNull: true,
    },
    comments_earning: {
      type: DataTypes.DECIMAL,
      allowNull: true,
    },
    total_earning: {
      type: DataTypes.DECIMAL,
      allowNull: true,
    },
    updated_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    tableName: 'member_earnings',
    timestamps: false, 
  }
)

export default MemberEarning;