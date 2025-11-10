import React from 'react';
import { render } from '@testing-library/react';

describe('Placeholder test', () => {
  it('renders without crashing', () => {
    const { container } = render(<div>Placeholder</div>);
    expect(container).toBeTruthy();
  });
});
