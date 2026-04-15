import {
  ApartmentOutlined,
  HomeOutlined,
  TeamOutlined,
} from '@ant-design/icons';
import type { ComponentType } from 'react';

export interface AppNavItem {
  description: string;
  href: string;
  icon: ComponentType;
  key: string;
  label: string;
}

export const appNavigation: AppNavItem[] = [
  {
    key: 'home',
    label: 'Overview',
    href: '/',
    description: 'Entry point and system summary',
    icon: HomeOutlined,
  },
  {
    key: 'companies',
    label: 'Companies',
    href: '/companies',
    description: 'Manage studios, vendors, and partners',
    icon: ApartmentOutlined,
  },
  {
    key: 'users',
    label: 'Users',
    href: '/users',
    description: 'Track members and permissions',
    icon: TeamOutlined,
  },
];
