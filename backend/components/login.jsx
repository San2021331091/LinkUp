import React, { useState } from 'react';
import styled, { keyframes } from 'styled-components';

const gradientShift = keyframes`
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
`;

const float = keyframes`
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-20px) rotate(5deg); }
`;

const pulse = keyframes`
  0%, 100% { transform: scale(1); opacity: 0.8; }
  50% { transform: scale(1.05); opacity: 1; }
`;

const PageWrapper = styled.div`
  display: flex;
  min-height: 100vh;
  width: 100%;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  background: #f8fafc;
`;

const LeftPanel = styled.div`
  flex: 1;
  position: relative;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 25%, #f093fb 50%, #4f46e5 75%, #6366f1 100%);
  background-size: 400% 400%;
  animation: ${gradientShift} 15s ease infinite;
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 60px;
  overflow: hidden;

  @media (max-width: 900px) {
    display: none;
  }
`;

const GlassOverlay = styled.div`
  position: absolute;
  inset: 0;
  background: radial-gradient(circle at 20% 30%, rgba(255,255,255,0.15) 0%, transparent 50%),
              radial-gradient(circle at 80% 70%, rgba(255,255,255,0.1) 0%, transparent 50%);
  pointer-events: none;
`;

const FloatingCircle = styled.div`
  position: absolute;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  animation: ${float} 6s ease-in-out infinite;

  &.c1 { width: 120px; height: 120px; top: 10%; right: 15%; animation-delay: 0s; }
  &.c2 { width: 80px;  height: 80px;  top: 60%; right: 20%; animation-delay: 2s; }
  &.c3 { width: 60px;  height: 60px;  bottom: 15%; left: 10%; animation-delay: 4s; }
  &.c4 { width: 40px;  height: 40px;  top: 30%; left: 20%; animation-delay: 1s; }
`;

const BrandBadge = styled.div`
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 8px 16px;
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.25);
  border-radius: 100px;
  color: white;
  font-size: 13px;
  font-weight: 500;
  width: fit-content;
  margin-bottom: 32px;
  position: relative;
  z-index: 2;

  &::before {
    content: '';
    width: 8px;
    height: 8px;
    background: #4ade80;
    border-radius: 50%;
    animation: ${pulse} 2s infinite;
  }
`;

const Heading = styled.h1`
  font-size: 56px;
  font-weight: 800;
  color: white;
  margin: 0 0 24px 0;
  line-height: 1.05;
  letter-spacing: -1.5px;
  position: relative;
  z-index: 2;
  text-shadow: 0 4px 20px rgba(0,0,0,0.15);

  span {
    background: linear-gradient(90deg, #fef3c7, #fbcfe8);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }
`;

const SubText = styled.p`
  font-size: 17px;
  color: rgba(255, 255, 255, 0.9);
  line-height: 1.6;
  max-width: 440px;
  margin: 0 0 40px 0;
  position: relative;
  z-index: 2;
`;

const FeatureList = styled.div`
  display: flex;
  flex-direction: column;
  gap: 16px;
  position: relative;
  z-index: 2;
`;

const FeatureItem = styled.div`
  display: flex;
  align-items: center;
  gap: 14px;
  color: white;
  font-size: 15px;
  font-weight: 500;

  .icon-box {
    width: 38px;
    height: 38px;
    border-radius: 10px;
    background: rgba(255, 255, 255, 0.2);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.3);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
  }
`;

const Footer = styled.div`
  position: absolute;
  bottom: 30px;
  left: 60px;
  color: rgba(255,255,255,0.7);
  font-size: 13px;
  z-index: 2;
`;

const RightPanel = styled.div`
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
  background: white;
`;

const LoginCard = styled.form`
  width: 100%;
  max-width: 420px;
  display: flex;
  flex-direction: column;
  align-items: center;
`;

const LogoWrapper = styled.div`
  display: flex;
  justify-content: center;
  margin-bottom: 24px;
  position: relative;

  &::after {
    content: '';
    position: absolute;
    inset: -10px;
    background: radial-gradient(circle, rgba(99, 102, 241, 0.2) 0%, transparent 70%);
    z-index: -1;
    filter: blur(20px);
  }
`;

const Logo = styled.img`
  width: 140px;
  height: 140px;
  object-fit: contain;
  border-radius: 24px;
  box-shadow: 0 20px 50px rgba(99, 102, 241, 0.25);
  transition: transform 0.3s ease;

  &:hover { transform: scale(1.05) rotate(-2deg); }
`;

const Title = styled.h2`
  font-size: 28px;
  font-weight: 700;
  color: #111827;
  margin: 0 0 8px 0;
  text-align: center;
  letter-spacing: -0.5px;
`;

const Subtitle = styled.p`
  font-size: 15px;
  color: #6b7280;
  margin: 0 0 36px 0;
  text-align: center;
`;

const InputGroup = styled.div`
  width: 100%;
  margin-bottom: 18px;
`;

const Label = styled.label`
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 8px;
  letter-spacing: 0.2px;
`;

const Input = styled.input`
  width: 100%;
  padding: 14px 16px;
  border: 1.5px solid #e5e7eb;
  border-radius: 12px;
  font-size: 15px;
  color: #111827;
  background: #f9fafb;
  transition: all 0.2s ease;
  box-sizing: border-box;
  outline: none;

  &:focus {
    border-color: #6366f1;
    background: white;
    box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.1);
  }

  &::placeholder { color: #9ca3af; }
`;

const ErrorMessage = styled.div`
  width: 100%;
  padding: 12px 16px;
  background: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 10px;
  color: #b91c1c;
  font-size: 14px;
  margin-bottom: 18px;
  text-align: center;
`;

const Button = styled.button`
  width: 100%;
  padding: 14px;
  border: none;
  border-radius: 12px;
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
  color: white;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  margin-top: 8px;
  letter-spacing: 0.3px;
  transition: all 0.2s ease;
  box-shadow: 0 8px 20px rgba(79, 70, 229, 0.3);

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 12px 28px rgba(79, 70, 229, 0.4);
  }

  &:active { transform: translateY(0); }
`;

const SmallNote = styled.p`
  margin-top: 24px;
  font-size: 13px;
  color: #9ca3af;
  text-align: center;
`;

const Login = (props) => {
  const { action, message } = props;
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  return (
    <PageWrapper>
      <LeftPanel>
        <GlassOverlay />
        <FloatingCircle className="c1" />
        <FloatingCircle className="c2" />
        <FloatingCircle className="c3" />
        <FloatingCircle className="c4" />

        <BrandBadge>System Online</BrandBadge>

        <Heading>
          Welcome to<br /><span>LinkUp Admin</span>
        </Heading>

        <SubText>
          Manage creators, videos, and earnings — all in one beautifully crafted dashboard built for your music & social platform.
        </SubText>

        <FeatureList>
          <FeatureItem>
            <div className="icon-box">👥</div>
            Manage Users & Creators
          </FeatureItem>
          <FeatureItem>
            <div className="icon-box">🎬</div>
            Curate Video Content
          </FeatureItem>
          <FeatureItem>
            <div className="icon-box">💰</div>
            Track Member Earnings
          </FeatureItem>
        </FeatureList>

        <Footer>© {new Date().getFullYear()} LinkUp. All rights reserved.</Footer>
      </LeftPanel>

      <RightPanel>
        <LoginCard method="POST" action={action}>
          <LogoWrapper>
            <Logo
              src="https://i.postimg.cc/vZp9Ypqv/linkup.png"
              alt="LinkUp"
            />
          </LogoWrapper>

          <Title>Sign in to LinkUp</Title>
          <Subtitle>Enter your credentials to access the admin panel</Subtitle>

          {message && <ErrorMessage>{message}</ErrorMessage>}

          <InputGroup>
            <Label htmlFor="email">Email Address</Label>
            <Input
              id="email"
              name="email"
              type="email"
              placeholder="admin@linkup.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </InputGroup>

          <InputGroup>
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              name="password"
              type="password"
              placeholder="••••••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </InputGroup>

          <Button type="submit">Sign In →</Button>

          <SmallNote>Secured admin access · Authorized personnel only</SmallNote>
        </LoginCard>
      </RightPanel>
    </PageWrapper>
  );
};

export default Login;