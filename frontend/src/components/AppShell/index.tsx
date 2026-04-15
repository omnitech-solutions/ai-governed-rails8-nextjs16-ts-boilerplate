'use client';

import type { PropsWithChildren } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Layout, Space, Tag, Typography } from 'antd';
import { ProLayout } from '@ant-design/pro-components';
import { appNavigation } from '@/config/navigation';
import { Logo, LogoMark } from '@/components/Logo';
import { useState } from 'react';

const { Paragraph, Text, Title } = Typography;

function getActiveItem(pathname: string) {
  return appNavigation.find((item) => pathname === item.href || pathname.startsWith(`${item.href}/`));
}

export function AppShell({ children }: PropsWithChildren) {
  const pathname = usePathname();
  const activeItem = getActiveItem(pathname);
  const [collapsed, setCollapsed] = useState(false);

  return (
    <div className="app-shell">
      <ProLayout
        className="app-shell__pro-layout"
        suppressHydrationWarning
        title="Wrapbook Projector"
        layout="side"
        fixSiderbar
        fixedHeader
        location={{ pathname }}
        siderWidth={288}
        collapsedWidth={80}
        defaultCollapsed={false}
        onCollapse={setCollapsed}
        token={{
          bgLayout: 'transparent',
          colorBgAppListIconHover: 'rgba(255,255,255,0.08)',
          header: {
            colorBgHeader: 'rgba(6, 13, 24, 0.88)',
            colorHeaderTitle: '#f5f7ff',
            colorTextMenu: '#9db0d0',
            colorTextMenuActive: '#ffffff',
            colorTextMenuSelected: '#ffffff',
          },
          pageContainer: {
            colorBgPageContainer: 'transparent',
          },
          sider: {
            colorBgMenuItemHover: 'rgba(255,255,255,0.08)',
            colorBgMenuItemSelected: 'rgba(80, 139, 255, 0.18)',
            colorMenuBackground: 'rgba(8, 16, 30, 0.92)',
            colorTextMenu: '#8fa3c4',
            colorTextMenuActive: '#ffffff',
            colorTextMenuSelected: '#ffffff',
            colorTextSubMenuSelected: '#ffffff',
          },
          menu: {
            collapsedWidth: 80,
          },
        }}
        route={{
          routes: appNavigation.map((item) => ({
            icon: <item.icon />,
            name: item.label,
            path: item.href,
          })),
        }}
        menuItemRender={(item, dom) => <Link href={item.path || '/'}>{dom}</Link>}
        headerTitleRender={() => (
          <div className="app-shell__header-title-wrap">
            <div>
              <Text className="app-shell__eyebrow">Operations Console</Text>
              <Space size={10} align="center">
                <Title level={3} className="app-shell__header-title">
                  {activeItem?.label || 'Workspace'}
                </Title>
                {activeItem && <Tag color="blue">{activeItem.key}</Tag>}
              </Space>
            </div>
          </div>
        )}
        actionsRender={() => [
          <span key="description" />,
        ]}
        menuHeaderRender={() => (
          <div className="app-shell__sidebar-header">
            <div className="app-shell__sidebar-brand-expanded">
              <Logo size="md" showText />
              <div className="app-shell__sidebar-divider" />
              <div className="app-shell__sidebar-meta">
                <span className="app-shell__sidebar-label">Operations Console</span>
                <span className="app-shell__sidebar-tag">Development</span>
              </div>
            </div>
            <div className="app-shell__sidebar-brand-collapsed">
              <LogoMark size="md" noBackground />
            </div>
          </div>
        )}
        footerRender={() => (
          <Layout.Footer className="app-shell__footer">
            <div className="app-shell__footer-main">
              <div className="app-shell__footer-brand">
                <Logo size="sm" showText />
              </div>
              <nav className="app-shell__footer-nav">
                <div className="app-shell__footer-nav-section">
                  <Text className="app-shell__footer-nav-title">Platform</Text>
                  <div className="app-shell__footer-nav-links">
                    <Link href="/companies">Companies</Link>
                    <Link href="/users">People</Link>
                  </div>
                </div>
                <div className="app-shell__footer-nav-section">
                  <Text className="app-shell__footer-nav-title">System</Text>
                  <div className="app-shell__footer-status">
                    <div className="app-shell__footer-status-item">
                      <span className="app-shell__footer-status-dot app-shell__footer-status-dot--live" />
                      <span className="app-shell__footer-status-label">API Online</span>
                    </div>
                    <div className="app-shell__footer-status-item">
                      <span className="app-shell__footer-status-dot app-shell__footer-status-dot--live" />
                      <span className="app-shell__footer-status-label">Client Ready</span>
                    </div>
                  </div>
                </div>
              </nav>
            </div>
            <div className="app-shell__footer-bar">
              <Text className="app-shell__footer-copyright">
                © 2024 Wrapbook Projector — Local Development Environment
              </Text>
              <div className="app-shell__footer-meta-pills">
                <span className="app-shell__footer-pill">Rails 7.1</span>
                <span className="app-shell__footer-pill">Next.js 14</span>
                <span className="app-shell__footer-pill">JSON:API</span>
              </div>
            </div>
          </Layout.Footer>
        )}
      >
        <div className="app-shell__content">{children}</div>
      </ProLayout>
    </div>
  );
}
