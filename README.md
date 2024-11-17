# Terraform EC2 Deployment

Este repositorio contiene configuraciones de Terraform para aprovisionar recursos en AWS EC2, facilitando pruebas y despliegues consistentes en entornos de desarrollo y producción.

## Características

- **Despliegue de Instancias EC2**: Provisión de instancias EC2 con configuraciones personalizables.
- **Configuración de Red**: Creación y gestión de VPC, subredes y grupos de seguridad.
- **Variables Parametrizables**: Uso de variables para una configuración flexible y reutilizable.
- **Salidas Informativas**: Outputs que proporcionan información clave sobre los recursos desplegados.

## Estructura del Proyecto

- `compute.tf`: Configuraciones relacionadas con las instancias EC2.
- `networking.tf`: Definiciones de red, incluyendo VPC, subredes y grupos de seguridad.
- `provider.tf`: Configuración del proveedor de AWS.
- `variables.tf`: Declaración de variables utilizadas en las configuraciones.
- `outputs.tf`: Definición de las salidas que proporciona Terraform tras el despliegue.
- `terraform.tfvars`: Archivo para asignar valores a las variables definidas.
- `shared_locals.tf`: Definición de locales compartidos para uso común en las configuraciones.
- `.gitignore`: Archivos y directorios ignorados por Git.
- `README.md`: Este documento.

## Requisitos Previos

- **Cuenta de AWS**: Credenciales con permisos adecuados para crear recursos.
- **Terraform**: Instalado en tu máquina local (se recomienda la versión 1.0 o superior).

## Uso

1. **Clonar el Repositorio**

   ```bash
   git clone git@github.com:lroquec/terraform-ec2.git
   cd terraform-ec2
   ```
2. **Inicializar Terraform**
      ```bash
   terraform init
   ```
3. **Revisar y Actualizar Variables**
   - Edita el archivo terraform.tfvars para establecer tus configuraciones personalizadas
4. **Planificar el Despliegue**
      ```bash
   terraform plan
   ```
5. **Aplicar la Configuración**
      ```bash
   terraform apply
   ```
