import express from 'express';
import AdminJS, { ComponentLoader } from 'adminjs';
import AdminJSExpress from '@adminjs/express';
import * as AdminJSSequelize from '@adminjs/sequelize';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import sequelize from './db.js';
import User from './models/user.js';
import Video from './models/video.js';
import MemberEarning from './models/member_earning.js';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Register the Sequelize adapter
AdminJS.registerAdapter({
  Resource: AdminJSSequelize.Resource,
  Database: AdminJSSequelize.Database,
});

// Component loader for custom dashboard
const componentLoader = new ComponentLoader();
const Components = {
  Dashboard: componentLoader.add('Dashboard', path.join(__dirname, 'components/dashboard')),
};
componentLoader.override('Login', path.join(__dirname, 'components/login'));

const start = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Connected to Supabase Postgres');

    const app = express();

    const admin = new AdminJS({
      rootPath: '/admin',
      componentLoader,
      dashboard: {
        component: Components.Dashboard,
      },
      resources: [
        {
          resource: User,
          options: {
            id: 'users',
            navigation: { name: 'Content', icon: 'User' },
            listProperties: ['uid', 'name', 'email', 'followers_count', 'created_at'],
            editProperties: [
              'name',
              'email',
              'image',
              'youtube',
              'facebook',
              'twitter',
              'instagram',
              'followers_count',
              'following',
            ],
            showProperties: [
              'uid',
              'name',
              'email',
              'image',
              'youtube',
              'facebook',
              'twitter',
              'instagram',
              'followers_count',
              'following',
              'created_at',
              'updated_at',
            ],
            properties: {
              uid: { isTitle: false },
              name: { isTitle: true },
              image: { type: 'string' },
              following: { type: 'string', isArray: true },
            },
          },
        },
        {
          resource: Video,
          options: {
            id: 'videos',
            navigation: { name: 'Content', icon: 'Video' },
            listProperties: [
              'id',
              'artist_song_name',
              'user_id',
              'likes_count',
              'comments_count',
              'created_at',
            ],
            properties: {
              id: { isTitle: false },
              artist_song_name: { isTitle: true },
              description_tags: { type: 'textarea' },
              video_url: { type: 'string' },
              thumbnail_url: { type: 'string' },
            },
          },
        },
        {
          resource: MemberEarning,
          options: {
            id: 'member_earnings',
            navigation: { name: 'Earnings', icon: 'DollarSign' },
            listProperties: [
              'id',
              'user_id',
              'video_id',
              'likes_earning',
              'comments_earning',
              'total_earning',
              'updated_at',
            ],
            editProperties: [
              'video_id',
              'user_id',
              'likes_earning',
              'comments_earning',
              'total_earning',
            ],
            showProperties: [
              'id',
              'video_id',
              'user_id',
              'likes_earning',
              'comments_earning',
              'total_earning',
              'updated_at',
            ],
            properties: {
              id: { isTitle: false },
              user_id: { isTitle: true },
              likes_earning: { type: 'number' },
              comments_earning: { type: 'number' },
              total_earning: { type: 'number' },
            },
          },
        },
      ],
      branding: {
        companyName: 'LinkUp Admin',
        logo: 'https://i.postimg.cc/vZp9Ypqv/linkup.png/',
        withMadeWithLove: false,
        theme: {
          colors: {
            primary100: '#4f46e5',
            primary80: '#6366f1',
            primary60: '#818cf8',
          },
        },
      },
    });

    if (process.env.NODE_ENV === 'production') {
      await admin.initialize();
    } else {
      await admin.watch();
    }

    const ADMIN = {
      email: process.env.USER_EMAIL,
      password: process.env.USER_PASSWORD,
    };

    const adminRouter = AdminJSExpress.buildAuthenticatedRouter(
      admin,
      {
        authenticate: async (email, password) => {
          if (email === ADMIN.email && password === ADMIN.password) return ADMIN
          return null
        },
        cookieName: 'adminjs',
        cookiePassword: process.env.SESSION_SECRET,
      },
      null,
      {
        resave: false,
        saveUninitialized: true,
        secret: process.env.SESSION_SECRET,
      }
    );
    app.use(admin.options.rootPath, adminRouter);
    app.get('/', (_req, res) => res.status(200).send("Your server is up and running! Access the admin panel at /admin"));
    const PORT = process.env.PORT;
    app.listen(PORT, () => {
      console.log(`🚀 AdminJS running at ${PORT}${admin.options.rootPath}`);
    });
  } catch (err) {
    console.error('❌ Failed to start:', err);
    process.exit(1);
  }
};

start();