/**
 * Generic Resource Form Dialog Component
 * Renders a form dialog using @rjsf/antd with Ant Design
 */

'use client';

import { useRef, useState } from 'react';
import { App, Alert, Button, Modal, Space, Typography } from 'antd';
import Form from '@rjsf/antd';
import validator from '@rjsf/validator-ajv8';
import type { JsonSchema } from '@/types/schema';
import { parseApiErrors, type ParsedErrors } from '@/lib/json-api';

const { Paragraph, Text } = Typography;

export interface ResourceFormDialogProps<T> {
  confirmLoading?: boolean;
  open: boolean;
  onClose: () => void;
  schema: JsonSchema;
  initialData?: T;
  resourceType: string;
  onSubmit: (data: T) => Promise<void>;
  title: string;
  isEdit?: boolean;
}

export function ResourceFormDialog<T extends Record<string, any>>({
  confirmLoading = false,
  open,
  onClose,
  schema,
  initialData,
  resourceType,
  onSubmit,
  title,
  isEdit = false,
}: ResourceFormDialogProps<T>) {
  const { message } = App.useApp();
  const formRef = useRef<any>(null);
  const formData = initialData ? { ...initialData } : {};
  const [errors, setErrors] = useState<ParsedErrors>({ baseErrors: [], fieldErrors: {} });
  const [hasSubmitted, setHasSubmitted] = useState(false);

  const handleSubmit = async ({ formData: submittedData }: { formData?: T }) => {
    try {
      if (!submittedData) {
        return;
      }

      // Remove id from create requests
      const dataToSubmit = isEdit ? submittedData : { ...submittedData };
      if (!isEdit && 'id' in dataToSubmit) {
        delete dataToSubmit.id;
      }

      setHasSubmitted(true);
      setErrors({ baseErrors: [], fieldErrors: {} });

      await onSubmit(dataToSubmit);
      message.success('Saved successfully');
      onClose();
    } catch (err) {
      const parsedErrors = parseApiErrors(err);
      setErrors(parsedErrors);
      
      if (parsedErrors.baseErrors.length > 0) {
        message.error('Failed to save. Please check the form for errors.');
      }
    }
  };

  // Build errorSchema for rjsf from fieldErrors
  const errorSchema: any = {};
  Object.entries(errors.fieldErrors).forEach(([field, errorMessage]) => {
    errorSchema[field] = {
      __errors: [errorMessage],
    };
  });

  // Reset errors when modal opens
  const handleOpenChange = (isOpen: boolean) => {
    if (!isOpen) {
      setErrors({ baseErrors: [], fieldErrors: {} });
      setHasSubmitted(false);
    }
  };

  return (
    <Modal
      open={open}
      onCancel={() => {
        handleOpenChange(false);
        onClose();
      }}
      title={null}
      footer={null}
      destroyOnHidden
      width={760}
      className="resource-form-modal"
    >
      <div className="resource-form-modal__header">
        <div>
          <Text className="resource-form-modal__eyebrow">{resourceType}</Text>
          <h2 className="resource-form-modal__title">{title}</h2>
          <Paragraph className="resource-form-modal__copy">
            {isEdit
              ? 'Update the selected record and save the changes back to the API.'
              : 'Use the schema-backed form below to create a new record.'}
          </Paragraph>
        </div>
      </div>

      {errors.baseErrors.length > 0 && (
        <Alert
          message="Error"
          description={
            <ul style={{ margin: 0, paddingLeft: 20 }}>
              {errors.baseErrors.map((error, index) => (
                <li key={index}>{error}</li>
              ))}
            </ul>
          }
          type="error"
          showIcon
          closable
          onClose={() => setErrors({ ...errors, baseErrors: [] })}
          style={{ marginBottom: 16 }}
        />
      )}

      <Form
        ref={formRef}
        schema={schema as any}
        validator={validator}
        formData={formData}
        onSubmit={handleSubmit}
        onError={() => message.error('Please fix the validation errors before saving.')}
        // @ts-ignore - RJSF 5.x/6.x prop compatibility
        errorSchema={errorSchema}
        className="resource-form-modal__form"
        uiSchema={{
          'ui:options': {
            label: false,
          },
        }}
        templates={{
          ButtonTemplates: {
            SubmitButton: () => null,
          },
        }}
      >
        <div className="resource-form-modal__footer">
          <Space size="middle">
            <Button onClick={() => { handleOpenChange(false); onClose(); }} size="large">
              Cancel
            </Button>
            <Button
              type="primary"
              size="large"
              loading={confirmLoading}
              onClick={() => formRef.current?.submit()}
            >
              {isEdit ? 'Save changes' : 'Create record'}
            </Button>
          </Space>
        </div>
      </Form>
    </Modal>
  );
}
