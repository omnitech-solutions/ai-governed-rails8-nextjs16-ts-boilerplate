import {
  BookOutlined,
  CodeOutlined,
  RocketOutlined,
} from '@ant-design/icons';
import { Button, Card, Row, Col, Tag, Space } from 'antd';

const techStack = [
  { name: 'Rails 8.1', tag: 'Backend' },
  { name: 'JSON:API', tag: 'Spec' },
  { name: 'Next.js 16', tag: 'Frontend' },
  { name: 'RSwag', tag: 'Docs' },
];

export default function Home() {
  return (
    <section className="overview-page">
      {/* Hero Section */}
      <div className="overview-page__hero">
        <div className="overview-page__hero-badge">
          <RocketOutlined /> Boilerplate Template
        </div>
        <h1 className="overview-page__title">
          Boilerplate App
        </h1>
        <p className="overview-page__subtitle">
          A production-ready foundation for modern web applications.
        </p>
        <p className="overview-page__copy">
          Built with Rails 8.1 JSON:API, Graphiti resources, and Next.js 16.
          This boilerplate provides a solid starting point with Ant Design, TanStack Query, and RSpec testing.
        </p>

        <Space wrap size="middle" className="overview-page__actions">
          <a href="http://localhost:3000/api-docs" target="_blank" rel="noopener noreferrer">
            <Button type="primary" size="large" icon={<BookOutlined />}>
              API Documentation
            </Button>
          </a>
        </Space>

        <div className="overview-page__tech-stack">
          {techStack.map((tech) => (
            <Tag key={tech.name} className="overview-page__tech-tag">
              {tech.name}
            </Tag>
          ))}
        </div>
      </div>

      {/* Developer Links */}
      <div className="overview-page__section">
        <h2 className="overview-page__section-title">
          <BookOutlined /> Developer Resources
        </h2>
        <Row gutter={[16, 16]}>
          <Col xs={24} md={12}>
            <Card className="overview-page__dev-card" variant="borderless">
              <div className="overview-page__dev-card-header">
                <CodeOutlined className="overview-page__dev-card-icon" />
                <h3>Interactive API Docs</h3>
              </div>
              <p className="overview-page__dev-card-desc">
                Explore endpoints, test requests, and understand the JSON:API schema with Swagger UI.
              </p>
              <a
                href="http://localhost:3000/api-docs"
                target="_blank"
                rel="noopener noreferrer"
                className="overview-page__dev-card-link"
              >
                Open Swagger UI →
              </a>
            </Card>
          </Col>
          <Col xs={24} md={12}>
            <Card className="overview-page__dev-card" variant="borderless">
              <div className="overview-page__dev-card-header">
                <RocketOutlined className="overview-page__dev-card-icon" />
                <h3>AI-Assisted Commands</h3>
              </div>
              <p className="overview-page__dev-card-desc">
                Use /feature, /endpoint, /refactor, and /test commands to accelerate development.
              </p>
              <div className="overview-page__dev-card-tags">
                <Tag>/feature</Tag>
                <Tag>/endpoint</Tag>
                <Tag>/refactor</Tag>
                <Tag>/test</Tag>
              </div>
            </Card>
          </Col>
        </Row>
      </div>
    </section>
  );
}
