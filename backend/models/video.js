import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const Video = sequelize.define(
  'Video',
  {
    id: {
      type: DataTypes.TEXT,
      primaryKey: true,
    },
    artist_song_name: { type: DataTypes.TEXT },
    description_tags: { type: DataTypes.TEXT },
    video_url: { type: DataTypes.TEXT },
    thumbnail_url: { type: DataTypes.TEXT },
    user_id: { type: DataTypes.UUID },
    likes_count: { type: DataTypes.INTEGER, defaultValue: 0 },
    comments_count: { type: DataTypes.INTEGER, defaultValue: 0 },
    created_at: { type: DataTypes.DATE },
  },
  {
    tableName: 'videos',
    schema: 'public',
    timestamps: false,
  }
);

export default Video;
