import React from 'react';

const Dashboard = () => {
  return (
    <div
      dangerouslySetInnerHTML={{
        __html: `
          <style>
            .tt-page {
              min-height: calc(100vh - 80px);
              background: #000;
              padding: 24px 16px;
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Helvetica Neue", Arial, sans-serif;
              -webkit-font-smoothing: antialiased;
            }
            .tt-wrap {
              max-width: 960px;
              margin: 0 auto;
              padding: 48px 24px;
              background: #161823;
              border-radius: 20px;
              text-align: center;
              color: #fff;
            }
            .tt-logo {
              display: inline-flex;
              align-items: center;
              gap: 10px;
              margin-bottom: 28px;
            }
            .tt-logo .note {
              font-size: 36px;
              filter: drop-shadow(0 0 8px rgba(37, 244, 238, 0.5));
            }
            .tt-logo .word {
              font-size: 36px;
              font-weight: 800;
              letter-spacing: -0.5px;
              position: relative;
              color: #fff;
              text-shadow:
                2px 2px 0 #fe2c55,
                -2px -2px 0 #25f4ee;
            }
            .tt-wrap h1 {
              font-size: clamp(24px, 5vw, 36px);
              margin: 0 0 12px;
              font-weight: 800;
              letter-spacing: -0.5px;
            }
            .tt-wrap p {
              font-size: clamp(14px, 2.5vw, 17px);
              color: #a8a8b3;
              margin: 0 auto 36px;
              line-height: 1.6;
              max-width: 560px;
            }
            .tt-cards {
              display: grid;
              grid-template-columns: repeat(3, 1fr);
              gap: 16px;
              margin-top: 8px;
            }
            .tt-card {
              display: block;
              padding: 28px 16px;
              background: #1f2030;
              border: 1px solid #2a2b3d;
              border-radius: 16px;
              text-decoration: none;
              color: #fff;
              transition: transform 0.2s ease, border-color 0.2s ease, box-shadow 0.2s ease;
              position: relative;
              overflow: hidden;
            }
            .tt-card::before {
              content: "";
              position: absolute;
              inset: 0;
              background: linear-gradient(135deg, rgba(37,244,238,0.0), rgba(254,44,85,0.0));
              transition: background 0.3s ease;
              pointer-events: none;
            }
            .tt-card:hover {
              transform: translateY(-3px);
              border-color: #fe2c55;
              box-shadow: 0 8px 24px rgba(254, 44, 85, 0.25);
            }
            .tt-card:hover::before {
              background: linear-gradient(135deg, rgba(37,244,238,0.08), rgba(254,44,85,0.12));
            }
            .tt-card .icon {
              font-size: 32px;
              margin-bottom: 10px;
              display: block;
            }
            .tt-card .label {
              font-size: 15px;
              font-weight: 700;
              letter-spacing: 0.2px;
            }
            .tt-card .sub {
              display: block;
              margin-top: 4px;
              font-size: 12px;
              color: #a8a8b3;
              font-weight: 500;
            }

            /* Tablet */
            @media (max-width: 720px) {
              .tt-wrap {
                padding: 36px 18px;
                border-radius: 16px;
              }
              .tt-logo .note,
              .tt-logo .word {
                font-size: 28px;
              }
              .tt-cards {
                grid-template-columns: repeat(2, 1fr);
                gap: 12px;
              }
            }

            /* Phone */
            @media (max-width: 480px) {
              .tt-page {
                padding: 16px 10px;
              }
              .tt-wrap {
                padding: 32px 16px;
              }
              .tt-cards {
                grid-template-columns: 1fr;
              }
              .tt-card {
                padding: 22px 16px;
                display: flex;
                align-items: center;
                gap: 14px;
                text-align: left;
              }
              .tt-card .icon {
                margin-bottom: 0;
                font-size: 26px;
              }
            }
          </style>
          <div class="tt-page">
            <div class="tt-wrap">
              <div class="tt-logo">
                <span class="note">🎵</span>
                <span class="word">Link Up</span>
              </div>
              <h1>Welcome to LinkUp Admin</h1>
              <p>Manage your creators, videos, and earnings — all from one place.</p>
              <div class="tt-cards">
                <a class="tt-card" href="/admin/resources/users">
                  <span class="icon">👥</span>
                  <span class="label">Users<span class="sub">Creators & followers</span></span>
                </a>
                <a class="tt-card" href="/admin/resources/videos">
                  <span class="icon">🎬</span>
                  <span class="label">Videos<span class="sub">Uploads & content</span></span>
                </a>
                <a class="tt-card" href="/admin/resources/member_earnings">
                  <span class="icon">💰</span>
                  <span class="label">Earnings<span class="sub">Likes & comments</span></span>
                </a>
              </div>
            </div>
          </div>
        `,
      }}
    />
  );
};

export default Dashboard;