jest.mock('@aws-sdk/client-ses', () => {
  const send = jest.fn();
  return {
    SESClient: jest.fn(() => ({ send })),
    SendEmailCommand: jest.fn((input) => ({ input })),
    __send: send,
  };
});

jest.mock('@aws-sdk/client-sqs', () => {
  const send = jest.fn();
  return {
    SQSClient: jest.fn(() => ({ send })),
    ReceiveMessageCommand: jest.fn((input) => ({ input, kind: 'receive' })),
    DeleteMessageCommand: jest.fn((input) => ({ input, kind: 'delete' })),
    __send: send,
  };
});

const ses = require('@aws-sdk/client-ses');
const sqs = require('@aws-sdk/client-sqs');
const { notificationLog, pollCloudQueue, sendEmail } = require('./index');

describe('notification-service AWS adapters', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    jest.clearAllMocks();
    notificationLog.length = 0;
    process.env = { ...originalEnv };
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  test('sends email through SES when EMAIL_BACKEND=ses', async () => {
    process.env.EMAIL_BACKEND = 'ses';
    process.env.FROM_EMAIL = 'noreply@cloudmart.example';

    await sendEmail('user@example.com', 'Subject', 'Body');

    expect(ses.SendEmailCommand).toHaveBeenCalledWith(expect.objectContaining({
      Source: 'noreply@cloudmart.example',
      Destination: { ToAddresses: ['user@example.com'] },
    }));
    expect(ses.__send).toHaveBeenCalledTimes(1);
  });

  test('polls SQS and deletes processed messages', async () => {
    process.env.QUEUE_BACKEND = 'sqs';
    process.env.EMAIL_BACKEND = 'console';
    process.env.SQS_QUEUE_URL = 'https://sqs.example/orders';
    sqs.__send
      .mockResolvedValueOnce({
        Messages: [{
          Body: JSON.stringify({
            type: 'ORDER_CREATED',
            orderId: 'ord-1',
            userId: 'user-1',
            total: 10,
            items: [{ name: 'Tea', quantity: 1, price: 10 }],
            timestamp: '2026-01-01T00:00:00Z',
          }),
          ReceiptHandle: 'receipt-1',
        }],
      })
      .mockResolvedValueOnce({});

    await pollCloudQueue();

    expect(sqs.ReceiveMessageCommand).toHaveBeenCalledWith(expect.objectContaining({
      QueueUrl: 'https://sqs.example/orders',
      MaxNumberOfMessages: 10,
    }));
    expect(sqs.DeleteMessageCommand).toHaveBeenCalledWith(expect.objectContaining({
      QueueUrl: 'https://sqs.example/orders',
      ReceiptHandle: 'receipt-1',
    }));
  });
});
