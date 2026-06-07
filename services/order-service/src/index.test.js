jest.mock('@aws-sdk/client-sqs', () => {
  const send = jest.fn();
  return {
    SQSClient: jest.fn(() => ({ send })),
    SendMessageCommand: jest.fn((input) => ({ input })),
    __send: send,
  };
});

const sqs = require('@aws-sdk/client-sqs');
const { eventLog, publishOrderEvent } = require('./index');

describe('publishOrderEvent', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    jest.clearAllMocks();
    eventLog.length = 0;
    process.env = { ...originalEnv };
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  test('publishes to SQS when QUEUE_BACKEND=sqs', async () => {
    process.env.QUEUE_BACKEND = 'sqs';
    process.env.SQS_QUEUE_URL = 'https://sqs.example/orders';
    process.env.AWS_REGION = 'ap-south-1';

    await publishOrderEvent({ type: 'ORDER_CREATED', orderId: 'ord-1' });

    expect(sqs.SendMessageCommand).toHaveBeenCalledWith(expect.objectContaining({
      QueueUrl: 'https://sqs.example/orders',
      MessageBody: JSON.stringify({ type: 'ORDER_CREATED', orderId: 'ord-1' }),
    }));
    expect(sqs.__send).toHaveBeenCalledTimes(1);
    expect(eventLog).toHaveLength(0);
  });

  test('uses memory event log by default', async () => {
    await publishOrderEvent({ type: 'ORDER_CREATED', orderId: 'ord-2' });

    expect(eventLog).toHaveLength(1);
    expect(sqs.__send).not.toHaveBeenCalled();
  });
});
