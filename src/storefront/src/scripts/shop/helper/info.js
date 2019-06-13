
const iconDir = 'images/tech/';
const toArray = obj => Object.keys(obj).map(k => obj[k]);
const iconPrefix = obj => toArray(obj).forEach(row => row.icon = row.icon && iconDir + row.icon);

export const TechType = {
  OCI: {
    name: 'Oracle Cloud Infrastructure',
    icon: 'oci.png',
    color: '#f80000',
  },
  // DOCKER: {
  //   name: 'Docker',
  //   icon: 'docker.svg',
  // },
  OKE: {
    name: 'Oracle Container Engine',
    icon: 'k8s.png',
    color: '#00758f',
  },
  // HELM: {
  //   name: 'Helm',
  //   icon: 'helm.svg',
  // },
};
// add icon paths
iconPrefix(TechType);

export const ServiceType = {
  // OCI Stuff
  ATP: {
    name: 'Oracle ATP',
    icon: 'atp.svg',
    scale: 2,
  },
  BUCKET: {
    name: 'Object Storage',
    icon: 'bucket.svg',
  },
  STREAMING: {
    name: 'Streaming',
    icon: 'streaming.svg',
  },
  // LB: {
  //   name: 'Load Balancer',
  //   icon: 'lb.svg',
  // },
  // VCN: {
  //   name: 'Virtual Cloud Network',
  //   icon: 'vcn.svg',
  // },
  // WAF: {
  //   name: 'Web Application Firewall',
  //   icon: 'waf.svg',
  // },
  // container technology
  JAVA: {
    name: 'Java',
    icon: 'java.png',
    scale: 1.5,
  },
  NODE: {
    name: 'Node.js',
    icon: 'nodejs.png',
  },
  REDIS: {
    name: 'Redis',
    icon: 'redis.png',
  },
  GO: {
    name: 'Go',
    icon: 'go.svg',
  },
  PYTHON: {
    name: 'Python',
    icon: 'python.svg',
  },
  NGINX: {
    name: 'Nginx',
    icon: 'nginx.png',
  },
  MONGO: {
    name: 'MongoDB',
    icon: 'mongo.png',
    scale: 1.2,
  },
};
// add icon paths
iconPrefix(ServiceType);


/**
 * Define services in application architecture
 */
export const Services = {
  // OCI Services
  BUCKET: {
    name: 'Bucket',
    type: ServiceType.BUCKET,
    tech: TechType.OCI,
  },
  ATP: {
    name: 'ATP Database',
    type: ServiceType.ATP,
    tech: TechType.OCI,
  },
  STREAMING: {
    name: 'OCI Stream',
    type: ServiceType.STREAMING,
    tech: TechType.OCI,
  },
  // Edge
  INGRESS: {
    name: 'Ingress Controller',
    type: ServiceType.NGINX,
    tech: TechType.OKE,
  },
  // OKE Services
  STORE: {
    name: 'Storefront UI',
    type: ServiceType.NGINX,
    tech: TechType.OKE,
  },
  API: {
    name: 'Client API',
    type: ServiceType.NODE,
    tech: TechType.OKE,
  },
  SESSION: {
    name: 'Session DB',
    type: ServiceType.REDIS,
    tech: TechType.OKE,
  },
  CATALOG: {
    name: 'Catalog',
    type: ServiceType.GO,
    tech: TechType.OKE,
  },
  CART: {
    name: 'Carts',
    type: ServiceType.JAVA,
    tech: TechType.OKE,
  },
  ORDERS: {
    name: 'Orders',
    type: ServiceType.JAVA,
    tech: TechType.OKE,
  },
  SHIPPING: {
    name: 'Shipping',
    type: ServiceType.JAVA,
    tech: TechType.OKE,
  },
  STREAM: {
    name: 'Stream Consumer',
    type: ServiceType.JAVA,
    tech: TechType.OKE,
  },
  PAYMENT: {
    name: 'Payment',
    type: ServiceType.GO,
    tech: TechType.OKE,
  },
  USER: {
    name: 'Users',
    type: ServiceType.GO,
    tech: TechType.OKE,
  },
  USERDB: {
    name: 'Users NoSQL',
    type: ServiceType.MONGO,
    tech: TechType.OKE,
  },
};

/**
 * Define service relationships
 */
export const ServiceLinks = [
  // ingress
  { source: Services.INGRESS, target: Services.STORE },
  { source: Services.INGRESS, target: Services.API },
  // ui
  { source: Services.STORE, target: Services.BUCKET },
  // api
  { source: Services.API, target: Services.SESSION },
  { source: Services.API, target: Services.CART },
  { source: Services.API, target: Services.CATALOG },
  { source: Services.API, target: Services.USER },
  { source: Services.API, target: Services.ORDERS },
  // User
  { source: Services.USER, target: Services.USERDB },
  // Catalog
  { source: Services.CATALOG, target: Services.ATP },
  { source: Services.CATALOG, target: Services.BUCKET },
  // Cart
  { source: Services.CART, target: Services.ATP },
  // Orders
  { source: Services.ORDERS, target: Services.ATP },
  { source: Services.ORDERS, target: Services.USER },
  { source: Services.ORDERS, target: Services.CART },
  { source: Services.ORDERS, target: Services.SHIPPING },
  { source: Services.ORDERS, target: Services.PAYMENT },
  // Ship
  { source: Services.SHIPPING, target: Services.STREAMING },
  { source: Services.STREAMING, target: Services.STREAM },

];